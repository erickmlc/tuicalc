#!/usr/bin/env bash
set -euo pipefail

# PR Body can be passed as an environment variable or via file argument
PR_BODY="${PR_BODY:-}"

if [[ -z "$PR_BODY" && $# -gt 0 && -f "$1" ]]; then
    PR_BODY=$(cat "$1")
fi

echo "=== Checking Pull Request Template Usage ==="

# Check if PR body is empty or whitespace only
CLEANED_BODY=$(echo "$PR_BODY" | tr -d '[:space:]')
if [[ -z "$CLEANED_BODY" ]]; then
    echo "::error::PR description is completely empty. Please use one of the PR templates in .github/PULL_REQUEST_TEMPLATE/."
    exit 1
fi

TEMPLATES_DIR=".github/PULL_REQUEST_TEMPLATE"
MATCHED=0
MATCHED_TEMPLATE=""

if [[ ! -d "$TEMPLATES_DIR" ]]; then
    echo "::error::Templates directory '$TEMPLATES_DIR' does not exist."
    exit 1
fi

# Define key sections expected for each template type
declare -A TEMPLATE_REQUIRED_SECTIONS=(
    ["pull_request_template.md"]="## Description|## Related Issue|## Change Type|## How to Test|## Checklist"
    ["bug_fix.md"]="## Description|## Related Issue|## Root Cause|## Solution Details|## How to Test / Reproduce|## Checklist"
    ["feature.md"]="## Description|## Related Issue|## Motivation & Context|## Key Changes|## Checklist"
    ["refactor.md"]="## Description|## Related Issue|## Scope of Changes|## Details of Changes|## Verification & Testing"
    ["documentation.md"]="## Description|## Related Issue|## Scope of Documentation|## Summary of Changes|## Checklist"
)

for tmpl in "$TEMPLATES_DIR"/*.md; do
    tmpl_file=$(basename "$tmpl")
    required_headers="${TEMPLATE_REQUIRED_SECTIONS[$tmpl_file]:-}"

    # Fallback: extract level 2 headers directly from the markdown file if not specified in mapping
    if [[ -z "$required_headers" ]]; then
	required_headers=$(grep -E '^## ' "$tmpl" | paste -sd '|' - || true)
    fi

    if [[ -z "$required_headers" ]]; then
	continue
    fi

    all_found=true
    IFS='|' read -ra HEADERS <<< "$required_headers"
    for header in "${HEADERS[@]}"; do
	if ! echo "$PR_BODY" | grep -F -q "$header"; then
	  all_found=false
	  break
	fi
    done

    if [[ "$all_found" == true ]]; then
	MATCHED=1
	MATCHED_TEMPLATE="$tmpl_file"
	break
    fi
done

if [[ "$MATCHED" -eq 1 ]]; then
    echo "✓ Successfully validated PR body against template: $MATCHED_TEMPLATE"
else
    echo "::error::PR body does not follow any expected PR template format (.github/PULL_REQUEST_TEMPLATE/*.md)."
    echo "Please ensure you have filled out the required template sections (e.g., Description, Related Issue, Checklist)."
    exit 1
fi

# Extract content of Description section up to the next level 2 header
DESC_CONTENT=$(echo "$PR_BODY" | awk '/^## Description/{flag=1; next} /^## /{flag=0} flag')
# Strip HTML comments and whitespace
CLEANED_DESC=$(echo "$DESC_CONTENT" | sed -E 's/<!--.*?-->//g' | tr -d '[:space:]')

if [[ -z "$CLEANED_DESC" ]]; then
    echo "::error::The 'Description' section is empty or contains only comments/placeholders."
    exit 1
fi

echo "PR template check passed successfully."
