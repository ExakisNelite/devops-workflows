# How Release Note Template Placeholders Work

## Supported Placeholders in the Template

The `release-note-template.md` template now supports the following placeholders:

### Basic Metadata

- `{VERSION}` : Release version (e.g., "1.2.3")
- `{RELEASE_DATE}` : Release date in yyyy-MM-dd format

### Aggregated Metrics

- `{USER_STORY_COUNT}` : Number of User Stories
- `{BUG_COUNT}` : Number of bugs fixed
- `{FEATURES_COUNT}` : Number of features (unique parents of User Stories)

### Dynamic Sections (Lists)

- `{WORK_ITEMS_TABLE_ROWS}` : Jira work items table rows
- `{NEW_FEATURES_SECTION}` : Detailed section for new features
- `{BUG_FIXES_SECTION}` : Detailed section for bug fixes
- `{PULL_REQUESTS_TABLE_ROWS}` : Associated Pull Requests table rows

## Replacement Example

### Before (template)

```markdown
## Work Items

| **Jira ID** | **Title** | **Type** |
| --- |  --- |  --- |
{WORK_ITEMS_TABLE_ROWS}
```

### After processing

```markdown
## Work Items

| **Jira ID** | **Title** | **Type** |
| --- |  --- |  --- |
| [CAP-123](https://meilleurtaux.atlassian.net/browse/CAP-123) | Improve API performance | Story |
| [CAP-124](https://meilleurtaux.atlassian.net/browse/CAP-124) | Fix connection bug | Bug |
```

## Technical Implementation

The `Set-ReleaseNoteContent` function:

1. Processes each simple placeholder through direct replacement
2. For lists, iterates over data and builds content dynamically
3. Generates valid Markdown with links to Jira and GitHub
4. Handles cases where no data is available

## Benefits of This Approach

- **Separation of concerns**: Template ≠ Processing logic
- **Easy maintenance**: Template can be modified without touching code
- **Extensibility**: New placeholders are easy to add
- **Reusability**: Different templates for different contexts
- **Readability**: Clear structure with explicit placeholders
