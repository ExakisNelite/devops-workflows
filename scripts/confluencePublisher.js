#!/usr/bin/env node
/*
  Confluence Smart Publisher (manifest-driven)
  - Reads a YAML manifest mapping .md files to Confluence pages (title, parent, labels)
  - Converts Markdown to HTML (Confluence Storage Format-compatible XHTML subset)
  - Creates or updates pages idempotently

  Env vars (via .env for local, or GH secrets in CI):
    CONFLUENCE_BASE_URL
    CONFLUENCE_EMAIL
    CONFLUENCE_API_TOKEN
    CONFLUENCE_SPACE_KEY
    CONFLUENCE_DEFAULT_PARENT_ID (optional)
*/

const fs = require('fs-extra');
const path = require('path');
const { program } = require('commander');
const YAML = require('yaml');
const axios = require('axios');
const FormData = require('form-data');
const MarkdownIt = require('markdown-it');
require('dotenv').config();

function escapeCData(text) {
    // Prevent breaking CDATA sections
    return text.replace(/]]>/g, ']]]]><![CDATA[>');
}

function mapLanguageAlias(lang) {
    if (!lang) return '';
    const l = String(lang).toLowerCase();
    const aliases = {
        // Web
        js: 'javascript', javascript: 'javascript', node: 'javascript',
        ts: 'typescript', typescript: 'typescript',
        html: 'html', css: 'css', scss: 'css', less: 'css',
        // C-family
        c: 'c', 'c++': 'cpp', cpp: 'cpp', cc: 'cpp',
        'c#': 'csharp', cs: 'csharp', csharp: 'csharp',
        'f#': 'fsharp', fsharp: 'fsharp',
        objc: 'objectivec', 'objective-c': 'objectivec', objectivec: 'objectivec',
        java: 'java', kotlin: 'kotlin', kt: 'kotlin', scala: 'scala', groovy: 'groovy', swift: 'swift',
        // Scripting & shells
        sh: 'bash', bash: 'bash', zsh: 'bash', shell: 'bash',
        ps: 'powershell', ps1: 'powershell', pwsh: 'powershell', powershell: 'powershell', cmd: 'text', bat: 'text', dos: 'text', batch: 'text',
        // Data/config
        json: 'json', json5: 'json', yaml: 'yaml', yml: 'yaml', toml: 'text', ini: 'text', properties: 'text', conf: 'text',
        xml: 'xml', xhtml: 'xml', svg: 'xml',
        // DBs
        sql: 'sql', tsql: 'sql', plsql: 'sql', mysql: 'sql', postgres: 'sql', postgresql: 'sql', mssql: 'sql', sqlite: 'sql',
        // Others common
        markdown: 'text', md: 'text', text: 'text', txt: 'text',
        python: 'python', py: 'python',
        ruby: 'ruby', rb: 'ruby',
        php: 'php',
        go: 'go', golang: 'go',
        rust: 'rust', rs: 'rust',
        r: 'r',
        matlab: 'matlab', m: 'matlab',
        perl: 'perl', pl: 'perl',
        lua: 'lua',
        haskell: 'haskell', hs: 'haskell',
        dart: 'dart',
        elixir: 'elixir',
        erlang: 'erlang',
        clojure: 'clojure', clj: 'clojure',
        scheme: 'scheme',
        lisp: 'lisp',
        ocaml: 'ocaml', ml: 'ocaml',
        vb: 'vb', vbnet: 'vb',
        dockerfile: 'text', makefile: 'text', gradle: 'text',
        nginx: 'text', apache: 'text', apacheconf: 'text',
        protobuf: 'protobuf', proto: 'protobuf',
        graphql: 'graphql', gql: 'graphql',
        bicep: 'bicep', hcl: 'text', terraform: 'text',
        kql: 'text',
        mermaid: 'text' // needs dedicated macro/plugin to render diagrams
    };
    if (aliases[l]) return aliases[l];
    // If the language label contains problematic chars and isn't explicitly mapped, drop it to avoid macro issues
    if (/[^a-z0-9-]/i.test(l)) return '';
    return l;
}

function codeMacro(code, { language, linenumbers, theme }) {
    const parts = [];
    if (language) parts.push(`<ac:parameter ac:name="language">${escapeXml(mapLanguageAlias(language))}</ac:parameter>`);
    if (linenumbers) parts.push(`<ac:parameter ac:name="linenumbers">true</ac:parameter>`);
    if (theme) parts.push(`<ac:parameter ac:name="theme">${escapeXml(theme)}</ac:parameter>`);
    parts.push(`<ac:plain-text-body><![CDATA[${escapeCData(code)}]]></ac:plain-text-body>`);
    return `<ac:structured-macro ac:name="code">${parts.join('')}</ac:structured-macro>`;
}

function makeMarkdownRenderer(codeBlockOptions) {
    const md = new MarkdownIt({ html: true, linkify: true, typographer: true });

    if (codeBlockOptions?.useCodeMacro !== false) {
        // Fenced code blocks ```lang
        md.renderer.rules.fence = (tokens, idx) => {
            const token = tokens[idx];
            const info = (token.info || '').trim();
            const lang = info.split(/\s+/)[0] || codeBlockOptions?.defaultLanguage || '';
            const linenumbers = !!codeBlockOptions?.lineNumbers;
            const theme = codeBlockOptions?.theme || undefined;
            return codeMacro(token.content, { language: lang, linenumbers, theme });
        };
        // Indented code blocks (4 spaces)
        md.renderer.rules.code_block = (tokens, idx) => {
            const token = tokens[idx];
            const lang = codeBlockOptions?.defaultLanguage || '';
            const linenumbers = !!codeBlockOptions?.lineNumbers;
            const theme = codeBlockOptions?.theme || undefined;
            return codeMacro(token.content, { language: lang, linenumbers, theme });
        };
    }
    return md;
}

program
    .requiredOption('-m, --manifest <file>', 'Path to YAML manifest')
    .option('--dry-run', 'Do not call Confluence APIs, just log actions')
    .parse(process.argv);

const options = program.opts();

async function readManifest(manifestPath) {
    const raw = await fs.readFile(manifestPath, 'utf8');
    // Support ${ENV} interpolation for settings
    const withEnv = raw.replace(/\$\{([A-Z0-9_]+)\}/g, (_, k) => process.env[k] ?? '');
    return YAML.parse(withEnv);
}

function assertEnv() {
    const required = ['CONFLUENCE_BASE_URL', 'CONFLUENCE_EMAIL', 'CONFLUENCE_API_TOKEN', 'CONFLUENCE_SPACE_KEY'];
    const missing = required.filter((k) => !process.env[k] || process.env[k].trim() === '');
    if (missing.length) {
        throw new Error(`Missing required env: ${missing.join(', ')}. Check .env or CI secrets.`);
    }
}

function buildAxios() {
    const baseURL = process.env.CONFLUENCE_BASE_URL.replace(/\/$/, '');
    const auth = {
        username: process.env.CONFLUENCE_EMAIL,
        password: process.env.CONFLUENCE_API_TOKEN,
    };
    return axios.create({
        baseURL: `${baseURL}/rest/api`,
        auth,
        headers: { 'Content-Type': 'application/json' },
    });
}

function mdToConfluenceStorage(markdown, codeBlockOptions) {
    // Convert Markdown to (X)HTML suitable for Confluence Storage rendering.
    const md = makeMarkdownRenderer(codeBlockOptions);
    const html = md.render(markdown);
    return html;
}

function buildManifestMap(manifest, baseDir) {
    const map = new Map();
    for (const entry of manifest.pages || []) {
        if (!entry.source || !entry.title) continue;
        const abs = path.resolve(baseDir, entry.source);
        map.set(path.normalize(abs), { title: entry.title });
    }
    return map;
}

function escapeXml(text) {
    return text
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;');
}

function normalizeMdHref(hrefRaw) {
    // trim surrounding spaces and quotes
    let href = hrefRaw.trim().replace(/^"|"$/g, '');
    // fix common typo: missing dot before md (e.g., item1md -> item1.md)
    if (/^[^.].*md$/i.test(href) && !href.endsWith('.md') && href.toLowerCase().endsWith('md')) {
        href = href.replace(/md$/i, '.md');
    }
    return href;
}

function replaceHtmlLinksWithConfluenceStorage(html, currentFile, manifestMap, spaceKey) {
    // Replace <a href="./file.md#anchor">Text</a> with Confluence storage link to page by title
    return html.replace(/<a\s+href="([^"]+)"[^>]*>([\s\S]*?)<\/a>/gi, (m, hrefRaw, body) => {
        const href = normalizeMdHref(hrefRaw);
        const bodyText = body.replace(/<[^>]+>/g, ''); // strip HTML tags in body for plain-text link body

        // Skip external links and mailto and page-local anchors
        if (/^(https?:)?\/\//i.test(href) || /^mailto:/i.test(href) || href.startsWith('#')) {
            return m;
        }

        // Split anchor if present
        const [filePart, anchor] = href.split('#');
        const candidate = filePart || '';
        if (!candidate) return m;

        // Only rewrite .md links
        if (!/\.md$/i.test(candidate)) return m;

        const targetAbs = path.normalize(path.resolve(path.dirname(currentFile), candidate));
        const target = manifestMap.get(targetAbs);
        if (!target) {
            // Unknown target, keep as is
            return m;
        }

        const titleXml = escapeXml(target.title);
        const bodyXml = escapeXml(bodyText || target.title);
        const anchorXml = anchor ? `<ac:anchor>${escapeXml(anchor)}</ac:anchor>` : '';
        const spaceAttr = spaceKey ? ` ri:space-key="${escapeXml(spaceKey)}"` : '';

        return `<ac:link>${anchorXml}<ri:page ri:content-title="${titleXml}"${spaceAttr} /><ac:plain-text-link-body><![CDATA[${bodyText || target.title}]]></ac:plain-text-link-body></ac:link>`;
    });
}

function replaceImagesWithConfluenceStorage(html, currentFile, spaceKey) {
    return replaceImagesWithConfluenceStorageWithOptions(html, currentFile, { normalizeFilenames: true });
}

function normalizeAttachmentFilename(name) {
    const idx = name.lastIndexOf('.');
    const base = idx >= 0 ? name.slice(0, idx) : name;
    const ext = idx >= 0 ? name.slice(idx).toLowerCase() : '';
    const baseStripped = base
        .normalize('NFKD')
        .replace(/[\u0300-\u036f]/g, '') // remove diacritics
        .toLowerCase()
        .replace(/[^a-z0-9._-]+/g, '-')
        .replace(/-+/g, '-')
        .replace(/^[-.]+|[-.]+$/g, '');
    const normalized = baseStripped || 'attachment';
    return `${normalized}${ext}`;
}

function replaceImagesWithConfluenceStorageWithOptions(html, currentFile, { normalizeFilenames }) {
    const attachments = [];

    const rewritten = html.replace(/<img\s+([^>]*?)src="([^"]+)"([^>]*)>/gi, (m, pre, srcRaw, post) => {
        const src = normalizeMdHref(srcRaw);
        // External or data URI -> use ri:url
        if (/^(https?:)?\/\//i.test(src) || /^data:/i.test(src)) {
            return `<ac:image><ri:url ri:value="${escapeXml(src)}" /></ac:image>`;
        }
        // Relative local path -> attachment
        const originalFilename = path.basename(src);
        const filename = normalizeFilenames ? normalizeAttachmentFilename(originalFilename) : originalFilename;
        const absPath = path.normalize(path.resolve(path.dirname(currentFile), src));
        attachments.push({ filename, absPath, originalFilename });
        return `<ac:image><ri:attachment ri:filename="${escapeXml(filename)}" /></ac:image>`;
    });

    return { html: rewritten, attachments };
}

async function ensureAttachment(api, pageId, attachment) {
    // Try to find existing attachment by filename
    const list = await api.get(`/content/${pageId}/child/attachment`, {
        params: { filename: attachment.filename, limit: 1 },
    });
    const existing = list.data?.results?.[0];

    const form = new FormData();
    form.append('file', fs.createReadStream(attachment.absPath), attachment.filename);

    const headers = { ...form.getHeaders(), 'X-Atlassian-Token': 'no-check' };

    if (existing) {
        // Update data to create a new version
        await api.post(`/content/${pageId}/child/attachment/${existing.id}/data`, form, { headers });
        return { action: 'updated', id: existing.id };
    }
    // Create new attachment
    const resp = await api.post(`/content/${pageId}/child/attachment`, form, { headers });
    return { action: 'created', id: resp.data?.results?.[0]?.id };
}

async function findPageByTitle(api, spaceKey, title) {
    const resp = await api.get('/content', {
        params: {
            spaceKey,
            title,
            expand: 'version',
            limit: 1,
        },
    });
    return resp.data.results?.[0] || null;
}

async function getPageById(api, id) {
    const resp = await api.get(`/content/${id}`, {
        params: { expand: 'version' },
    });
    return resp.data;
}

async function ensurePageExists(api, { spaceKey, title, parentId }) {
    const existing = await findPageByTitle(api, spaceKey, title);
    if (existing) return { action: 'existing', page: existing };
    const payload = {
        type: 'page',
        title,
        space: { key: spaceKey },
        ancestors: parentId ? [{ id: String(parentId) }] : undefined,
        body: {
            storage: {
                value: '<p></p>',
                representation: 'storage',
            },
        },
    };
    const resp = await api.post('/content', payload);
    return { action: 'created', page: resp.data };
}

async function updatePageBody(api, { pageId, title, parentId, storageBody }) {
    const latest = await getPageById(api, pageId);
    const newVersion = (latest.version?.number || 1) + 1;
    const payload = {
        id: pageId,
        type: 'page',
        title,
        version: { number: newVersion },
        ancestors: parentId ? [{ id: String(parentId) }] : undefined,
        body: {
            storage: {
                value: storageBody,
                representation: 'storage',
            },
        },
    };
    const resp = await api.put(`/content/${pageId}`, payload);
    return resp.data;
}

async function applyLabels(api, pageId, labels) {
    if (!labels?.length) return;
    await api.post(`/content/${pageId}/label`, labels.map((name) => ({ prefix: 'global', name })));
}

async function resolveParentId(api, spaceKey, parent) {
    if (!parent) return process.env.CONFLUENCE_DEFAULT_PARENT_ID || undefined;
    if (parent.id) return parent.id;
    if (parent.title) {
        const found = await findPageByTitle(api, spaceKey, parent.title);
        if (!found) throw new Error(`Parent page with title "${parent.title}" not found in space ${spaceKey}`);
        return found.id;
    }
    return undefined;
}

async function run() {
    const manifest = await readManifest(path.resolve(options.manifest));
    const dryRun = options.dryRun || manifest?.settings?.dryRun;
    const spaceKey = manifest?.settings?.spaceKey || process.env.CONFLUENCE_SPACE_KEY;
    const normalizeFilenames = manifest?.settings?.normalizeAttachmentFilenames !== false; // default true
    const codeBlockOptions = {
        useCodeMacro: manifest?.settings?.codeBlock?.useCodeMacro !== false,
        defaultLanguage: manifest?.settings?.codeBlock?.defaultLanguage || '',
        lineNumbers: !!manifest?.settings?.codeBlock?.lineNumbers,
        theme: manifest?.settings?.codeBlock?.theme || undefined,
    };

    let api = null;
    if (!dryRun) {
        assertEnv();
        api = buildAxios();
    }

    // Build map of source .md -> page title for link rewriting
    // Use the directory of the manifest file as the base directory for resolving source paths
    const manifestDir = path.dirname(path.resolve(options.manifest));
    const manifestMap = buildManifestMap(manifest, manifestDir);

    for (const entry of manifest.pages || []) {
        const srcPath = path.resolve(manifestDir, entry.source);
        const exists = await fs.pathExists(srcPath);
        if (!exists) throw new Error(`Source file not found: ${entry.source}`);
        const markdown = await fs.readFile(srcPath, 'utf8');
        let storageBody = mdToConfluenceStorage(markdown, codeBlockOptions);
        // Replace page links
        storageBody = replaceHtmlLinksWithConfluenceStorage(storageBody, srcPath, manifestMap, spaceKey);
        // Replace images and collect attachments
        const img = replaceImagesWithConfluenceStorageWithOptions(storageBody, srcPath, { normalizeFilenames });
        storageBody = img.html;
        const attachments = img.attachments;

        let parentId;
        if (dryRun) {
            // In dry-run, avoid API calls; prefer provided parent.id or default env
            parentId = entry.parent?.id || process.env.CONFLUENCE_DEFAULT_PARENT_ID || undefined;
        } else {
            parentId = await resolveParentId(api, spaceKey, entry.parent);
        }
        const labels = entry.labels || [];
        const upsert = entry.upsert !== false; // default true

        if (dryRun) {
            console.log(`[DRY-RUN] Would publish: title="${entry.title}", space=${spaceKey}, parentId=${parentId || '-'}, labels=${labels.join(',')}`);
            if (attachments.length) {
                const list = attachments.map(a => a.originalFilename && a.originalFilename !== a.filename
                    ? `${a.originalFilename} -> ${a.filename}`
                    : a.filename).join(', ');
                console.log(`[DRY-RUN] Would upload attachments: ${list}`);
            }
            continue;
        }

        // Ensure page exists (create stub if needed)
        const ensured = await ensurePageExists(api, { spaceKey, title: entry.title, parentId });
        console.log(`Page ${ensured.action}: ${entry.title} (id=${ensured.page.id})`);

        // Upload or update attachments first to guarantee immediate rendering
        for (const att of attachments) {
            const exists = await fs.pathExists(att.absPath);
            if (!exists) {
                throw new Error(`Attachment not found on disk: ${att.absPath}`);
            }
            const ar = await ensureAttachment(api, ensured.page.id, att);
            console.log(`Attachment ${ar.action}: ${att.filename}`);
        }

        // Now update the page body with final storage content
        await updatePageBody(api, { pageId: ensured.page.id, title: entry.title, parentId, storageBody });
        console.log(`Page updated content: ${entry.title} (id=${ensured.page.id})`);

        // Apply labels at the end
        await applyLabels(api, ensured.page.id, labels);
    }
}

run()
    .then(() => {
        process.exit(0);
    })
    .catch((err) => {
        console.error('Publishing failed:', err.response?.data || err.message || err);
        process.exit(1);
    });
