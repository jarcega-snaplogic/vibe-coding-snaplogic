#!/bin/bash
# Comprehensive SnapLogic Pipeline Validation Tool
# More detailed validation than the git hook for development and debugging

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage function
usage() {
    echo "Usage: $0 [options] <pipeline.slp>"
    echo ""
    echo "Options:"
    echo "  -v, --verbose    Verbose output with detailed validation info"
    echo "  -q, --quiet      Quiet mode - only show errors"
    echo "  -j, --json       Output results in JSON format"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 pipeline.slp                    # Basic validation"
    echo "  $0 -v pipeline.slp                 # Verbose validation"
    echo "  $0 -j pipeline.slp | jq .          # JSON output"
    echo ""
    exit 1
}

# Parse command line arguments
VERBOSE=false
QUIET=false
JSON_OUTPUT=false
FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -j|--json)
            JSON_OUTPUT=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ -z "$FILE" ]]; then
                FILE="$1"
            else
                echo "Error: Multiple files specified. This tool validates one file at a time."
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if file was provided
if [[ -z "$FILE" ]]; then
    echo "Error: No pipeline file specified."
    usage
fi

# Check if file exists
if [[ ! -f "$FILE" ]]; then
    echo "Error: File '$FILE' not found."
    exit 1
fi

# Initialize validation results
VALIDATION_RESULTS=()
ERROR_COUNT=0
WARNING_COUNT=0

# Helper functions
log_info() {
    if [[ "$QUIET" != true ]]; then
        echo -e "${BLUE}ℹ${NC} $1"
    fi
}

log_success() {
    if [[ "$QUIET" != true ]]; then
        echo -e "${GREEN}✅${NC} $1"
    fi
}

log_warning() {
    WARNING_COUNT=$((WARNING_COUNT + 1))
    if [[ "$QUIET" != true ]]; then
        echo -e "${YELLOW}⚠${NC} $1"
    fi
    VALIDATION_RESULTS+=("WARNING: $1")
}

log_error() {
    ERROR_COUNT=$((ERROR_COUNT + 1))
    echo -e "${RED}❌${NC} $1" >&2
    VALIDATION_RESULTS+=("ERROR: $1")
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}  →${NC} $1"
    fi
}

# Validation functions
validate_json_syntax() {
    log_info "Validating JSON syntax..."
    
    if python3 -m json.tool "$FILE" >/dev/null 2>&1; then
        log_success "JSON syntax is valid"
        log_verbose "File successfully parsed as valid JSON"
    else
        local error_output=$(python3 -m json.tool "$FILE" 2>&1)
        log_error "JSON syntax error: $error_output"
        return 1
    fi
}

validate_pipeline_structure() {
    log_info "Validating SnapLogic pipeline structure..."
    
    # Check for pipeline class_id
    if grep -q '"class_id": "com-snaplogic-pipeline"' "$FILE"; then
        log_success "Pipeline class_id found"
        log_verbose "Found: com-snaplogic-pipeline"
    else
        log_error "Missing pipeline class_id: com-snaplogic-pipeline"
        return 1
    fi
    
    # Count snaps
    local snap_count=$(grep -c '"class_id": "com-snaplogic-snaps-' "$FILE")
    log_verbose "Found $snap_count snap(s)"
    
    # Count links
    local link_count=$(grep -c '"link[0-9]*":' "$FILE")
    log_verbose "Found $link_count link(s)"
    
    # Validate snap/link relationship
    if [[ $snap_count -gt 1 ]]; then
        local expected_links=$((snap_count - 1))
        if [[ $link_count -eq $expected_links ]]; then
            log_success "Snap/link count is consistent ($snap_count snaps, $link_count links)"
        else
            log_error "Snap/link count mismatch: $snap_count snaps should have $expected_links links, found $link_count"
            return 1
        fi
    elif [[ $snap_count -eq 1 ]]; then
        if [[ $link_count -eq 0 ]]; then
            log_success "Single snap pipeline (no links expected)"
        else
            log_warning "Single snap pipeline has $link_count links (unusual but may be valid)"
        fi
    else
        log_error "No snaps found in pipeline"
        return 1
    fi
}

validate_uuids() {
    log_info "Validating UUID consistency..."
    
    # Extract UUIDs from different sections
    local link_uuids=$(grep -oE '"(src_id|dst_id)": "11111111-1111-1111-1111-[0-9]{12}"' "$FILE" | \
                      grep -oE '11111111-1111-1111-1111-[0-9]{12}' | sort -u)
    
    local snap_map_uuids=$(grep -A 1000 '"snap_map"' "$FILE" | \
                          grep -oE '"11111111-1111-1111-1111-[0-9]{12}": {' | \
                          grep -oE '11111111-1111-1111-1111-[0-9]{12}' | sort -u)
    
    # Check if all link UUIDs exist in snap_map
    local missing_uuids=()
    for uuid in $link_uuids; do
        if ! echo "$snap_map_uuids" | grep -q "$uuid"; then
            missing_uuids+=("$uuid")
        fi
    done
    
    if [[ ${#missing_uuids[@]} -eq 0 ]]; then
        log_success "All UUIDs are consistent between link_map and snap_map"
        log_verbose "Validated $(echo "$link_uuids" | wc -w) unique UUIDs"
    else
        for uuid in "${missing_uuids[@]}"; do
            log_error "UUID $uuid referenced in link_map but not found in snap_map"
        done
        return 1
    fi
}

validate_required_fields() {
    log_info "Validating required pipeline fields..."
    
    local required_fields=(
        '"class_id"'
        '"class_version"'
        '"property_map"'
        '"snap_map"'
    )
    
    for field in "${required_fields[@]}"; do
        if grep -q "$field" "$FILE"; then
            log_verbose "Found required field: $field"
        else
            log_error "Missing required field: $field"
            return 1
        fi
    done
    
    log_success "All required fields present"
}

generate_json_output() {
    local exit_code=$1
    local status="success"
    if [[ $exit_code -ne 0 ]]; then
        status="failed"
    fi
    
    # Convert validation results to JSON array
    local results_json="["
    local first=true
    for result in "${VALIDATION_RESULTS[@]}"; do
        if [[ "$first" != true ]]; then
            results_json+=","
        fi
        results_json+="\"$result\""
        first=false
    done
    results_json+="]"
    
    cat <<EOF
{
  "file": "$FILE",
  "status": "$status",
  "error_count": $ERROR_COUNT,
  "warning_count": $WARNING_COUNT,
  "validation_results": $results_json,
  "summary": {
    "json_syntax": "$(grep -q 'ERROR.*JSON' <<< "${VALIDATION_RESULTS[*]}" && echo 'failed' || echo 'passed')",
    "pipeline_structure": "$(grep -q 'ERROR.*structure\|ERROR.*count\|ERROR.*snap' <<< "${VALIDATION_RESULTS[*]}" && echo 'failed' || echo 'passed')",
    "uuid_consistency": "$(grep -q 'ERROR.*UUID' <<< "${VALIDATION_RESULTS[*]}" && echo 'failed' || echo 'passed')",
    "required_fields": "$(grep -q 'ERROR.*field' <<< "${VALIDATION_RESULTS[*]}" && echo 'failed' || echo 'passed')"
  }
}
EOF
}

# Main validation execution
main() {
    if [[ "$QUIET" != true ]]; then
        echo "🔍 Validating SnapLogic pipeline: $FILE"
        echo ""
    fi
    
    local validation_passed=true
    
    # Run all validations
    validate_json_syntax || validation_passed=false
    validate_pipeline_structure || validation_passed=false  
    validate_uuids || validation_passed=false
    validate_required_fields || validation_passed=false
    
    # Generate output
    if [[ "$JSON_OUTPUT" == true ]]; then
        if [[ "$validation_passed" == true ]]; then
            generate_json_output 0
        else
            generate_json_output 1
        fi
    else
        echo ""
        if [[ "$validation_passed" == true ]]; then
            log_success "Pipeline validation passed! ✨"
            if [[ $WARNING_COUNT -gt 0 ]]; then
                echo -e "${YELLOW}Note: $WARNING_COUNT warning(s) found${NC}"
            fi
        else
            echo -e "${RED}Pipeline validation failed!${NC}"
            echo -e "${RED}Errors: $ERROR_COUNT, Warnings: $WARNING_COUNT${NC}"
        fi
    fi
    
    # Exit with appropriate code
    if [[ "$validation_passed" == true ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main