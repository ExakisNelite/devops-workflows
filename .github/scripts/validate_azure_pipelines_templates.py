#!/usr/bin/env python3
"""Validate Azure DevOps pipeline templates.

Checks performed on every YAML file under the templates directory:

1. Root structure: each template must declare exactly one of the
   'stages', 'jobs' or 'steps' root keys, plus a 'parameters' block.
2. Parameters: each parameter must have a 'name' and a valid 'type'.
3. Cross-references: every '- template: xxx.yml' reference must point to
   an existing template file, and every parameter passed to a local
   template must be declared in that template.
4. Documentation sync: each template must have a documentation page in
   the docs directory, and every parameter must be documented there.

Usage:
    python .github/scripts/validate_azure_pipelines_templates.py \
        --templates-dir azure-pipelines/templates \
        --docs-dir azure-pipelines/docs
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML is required. Install it with: pip install pyyaml")
    sys.exit(2)

VALID_PARAM_TYPES = {"string", "number", "boolean", "object", "step", "stepList", "job", "jobList", "deployment", "deploymentList", "stage", "stageList"}

# Azure DevOps compile-time expression wrappers that may surround values
EXPR_PATTERN = re.compile(r"\$\{\{.*\}\}")


def load_template(path: Path) -> dict | None:
    """Load a template file, returning the parsed document or None on error."""
    try:
        return yaml.safe_load(path.read_text(encoding="utf-8"))
    except yaml.YAMLError as exc:
        print(f"ERROR: {path}: invalid YAML: {exc}")
        return None


def get_parameters(doc: dict) -> dict[str, dict]:
    """Return a mapping of parameter name -> parameter definition."""
    params = {}
    for param in doc.get("parameters") or []:
        if isinstance(param, dict) and "name" in param:
            params[param["name"]] = param
    return params


def check_root_structure(path: Path, doc: dict, errors: list[str]) -> None:
    root_keys = [k for k in ("stages", "jobs", "steps") if k in doc]
    if len(root_keys) != 1:
        errors.append(
            f"{path.name}: expected exactly one of 'stages'/'jobs'/'steps' root keys, "
            f"found: {root_keys or 'none'}"
        )
    if "parameters" not in doc:
        errors.append(f"{path.name}: missing 'parameters' block")


def check_parameters(path: Path, params: dict[str, dict], errors: list[str]) -> None:
    for name, param in params.items():
        if not name or not isinstance(name, str):
            errors.append(f"{path.name}: parameter with invalid name: {name!r}")
        ptype = param.get("type")
        if ptype not in VALID_PARAM_TYPES:
            errors.append(f"{path.name}: parameter '{name}' has missing/invalid type: {ptype!r}")
        if "default" in param and param["default"] is not None:
            default = param["default"]
            if ptype == "boolean" and not isinstance(default, bool):
                errors.append(f"{path.name}: parameter '{name}' boolean default is not a boolean: {default!r}")
            if ptype == "number" and not isinstance(default, (int, float)):
                errors.append(f"{path.name}: parameter '{name}' number default is not a number: {default!r}")
        # Secrets must never have a default value
        if "secret" in name.lower() and param.get("default"):
            errors.append(f"{path.name}: parameter '{name}' looks like a secret but has a default value")


def iter_template_references(node, references: list[dict]):
    """Recursively collect every 'template' reference with its parameters."""
    if isinstance(node, dict):
        if "template" in node:
            references.append(node)
        for value in node.values():
            iter_template_references(value, references)
    elif isinstance(node, list):
        for item in node:
            iter_template_references(item, references)


def check_template_references(
    path: Path,
    doc: dict,
    templates_dir: Path,
    known_params: dict[str, dict[str, dict]],
    errors: list[str],
) -> None:
    references: list[dict] = []
    iter_template_references(doc, references)

    for ref in references:
        template_value = str(ref.get("template", ""))
        # Skip expressions and external (repository alias) references
        if EXPR_PATTERN.search(template_value) or "@" in template_value:
            continue

        target = (templates_dir / template_value).resolve()
        if not target.is_file():
            errors.append(f"{path.name}: referenced template not found: {template_value}")
            continue

        target_params = known_params.get(target.name)
        if target_params is None:
            continue

        passed = ref.get("parameters") or {}
        if not isinstance(passed, dict):
            errors.append(f"{path.name}: 'parameters' of reference to {template_value} is not a mapping")
            continue

        for passed_name in passed:
            if passed_name not in target_params:
                errors.append(
                    f"{path.name}: parameter '{passed_name}' passed to {template_value} "
                    f"is not declared in that template"
                )

        # Warn (as error) if required parameters of the target are missing
        for target_name, target_def in target_params.items():
            if "default" not in target_def and target_name not in passed:
                errors.append(
                    f"{path.name}: required parameter '{target_name}' of {template_value} is not provided"
                )


def check_documentation_sync(
    path: Path,
    params: dict[str, dict],
    docs_dir: Path,
    errors: list[str],
) -> None:
    doc_file = docs_dir / f"{path.stem}.md"
    if not doc_file.is_file():
        errors.append(f"{path.name}: missing documentation page: {doc_file.relative_to(docs_dir.parent)}")
        return

    doc_text = doc_file.read_text(encoding="utf-8")
    for name in params:
        # Parameter names appear as the first cell of a markdown table row
        if not re.search(rf"\|\s*{re.escape(name)}\s*\|", doc_text):
            errors.append(f"{path.name}: parameter '{name}' is not documented in {doc_file.name}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--templates-dir", default="azure-pipelines/templates")
    parser.add_argument("--docs-dir", default="azure-pipelines/docs")
    args = parser.parse_args()

    templates_dir = Path(args.templates_dir)
    docs_dir = Path(args.docs_dir)

    if not templates_dir.is_dir():
        print(f"ERROR: templates directory not found: {templates_dir}")
        return 2

    errors: list[str] = []
    documents: dict[Path, dict] = {}
    known_params: dict[str, dict[str, dict]] = {}

    template_files = sorted(templates_dir.glob("*.yml")) + sorted(templates_dir.glob("*.yaml"))
    if not template_files:
        print(f"ERROR: no template files found in {templates_dir}")
        return 2

    for path in template_files:
        doc = load_template(path)
        if doc is None or not isinstance(doc, dict):
            errors.append(f"{path.name}: could not parse template")
            continue
        documents[path] = doc
        known_params[path.name] = get_parameters(doc)

    for path, doc in documents.items():
        params = known_params[path.name]
        check_root_structure(path, doc, errors)
        check_parameters(path, params, errors)
        check_template_references(path, doc, templates_dir, known_params, errors)
        if docs_dir.is_dir():
            check_documentation_sync(path, params, docs_dir, errors)

    print(f"Checked {len(documents)} Azure DevOps template(s).")
    if errors:
        print(f"\n{len(errors)} error(s) found:")
        for error in errors:
            print(f"  - {error}")
        return 1

    print("All Azure DevOps templates are valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
