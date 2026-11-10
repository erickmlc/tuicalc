# PR Template validation functions

validate_pr_body_not_empty() {
    local body="$1"
    local cleaned_body
    cleaned_body=$(echo "$body" | tr -d '[:space:]')
    if [[ -z "$cleaned_body" ]]; then
        echo "::error::PR description is completely empty. Please use one of the PR templates in .github/PULL_REQUEST_TEMPLATE/."
        return 1
    fi
    return 0
}

validate_description_content() {
    local body="$1"
    local desc_content cleaned_desc
    # Extract content of Description section up to the next level 2 header
    desc_content=$(echo "$body" | awk '/^## Description/{flag=1; next} /^## /{flag=0} flag')
    # Strip HTML comments and whitespace
    cleaned_desc=$(echo "$desc_content" | sed -E 's/<!--.*?-->//g' | tr -d '[:space:]')

    if [[ -z "$cleaned_desc" ]]; then
        echo "::error::The 'Description' section is empty or contains only comments/placeholders."
        return 1
    fi
    return 0
}

match_pr_template() {
    local body="$1"
    local templates_dir="${2:-.github/PULL_REQUEST_TEMPLATE}"

    if [[ ! -d "$templates_dir" ]]; then
        echo "::error::Templates directory '$templates_dir' does not exist."
        return 1
    fi

    # Define key sections expected for each template type
    declare -A template_required_sections=(
        ["pull_request_template.md"]="## Description|## Related Issue|## Change Type|## How to Test|## Checklist"
        ["bug_fix.md"]="## Description|## Related Issue|## Root Cause|## Solution Details|## How to Test / Reproduce|## Checklist"
        ["feature.md"]="## Description|## Related Issue|## Motivation & Context|## Key Changes|## Checklist"
        ["refactor.md"]="## Description|## Related Issue|## Scope of Changes|## Details of Changes|## Verification & Testing"
        ["documentation.md"]="## Description|## Related Issue|## Scope of Documentation|## Summary of Changes|## Checklist"
    )

    local matched=0
    local matched_template=""

    for tmpl in "$templates_dir"/*.md; do
        [[ -f "$tmpl" ]] || continue
        local tmpl_file
        tmpl_file=$(basename "$tmpl")
        local required_headers="${template_required_sections[$tmpl_file]:-}"

        # Fallback: extract level 2 headers directly from the markdown file if not specified in mapping
        if [[ -z "$required_headers" ]]; then
            required_headers=$(grep -E '^## ' "$tmpl" | paste -sd '|' - || true)
        fi

        if [[ -z "$required_headers" ]]; then
            continue
        fi

        local all_found=true
        local headers=()
        IFS='|' read -ra headers <<< "$required_headers"
        for header in "${headers[@]}"; do
            if ! echo "$body" | grep -F -q "$header"; then
                all_found=false
                break
            fi
        done

        if [[ "$all_found" == true ]]; then
            matched=1
            matched_template="$tmpl_file"
            break
        fi
    done

    if [[ "$matched" -eq 1 ]]; then
        echo "✓ Successfully validated PR body against template: $matched_template"
        return 0
    else
        echo "::error::PR body does not follow any expected PR template format (.github/PULL_REQUEST_TEMPLATE/*.md)."
        echo "Please ensure you have filled out the required template sections (e.g., Description, Related Issue, Checklist)."
        return 1
    fi
}
