#!/bin/bash
#
# Ollama Skills Library — Setup Script (Bash)
# ============================================
# Converts SKILL.md files to Modelfiles and builds Ollama models.
#
# Usage:
#   bash setup.sh --all                    # Build all bundles
#   bash setup.sh --bundle legal           # Build only legal bundle
#   bash setup.sh --skill legal/contract   # Build specific skill
#   bash setup.sh --dry-run                # Preview without building
#   bash setup.sh --base-model mistral     # Use different base model
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
BASE_MODEL="${BASE_MODEL:-llama3.2}"
DRY_RUN=false
BUNDLE_FILTER=""
SKILL_FILTER=""

# ============================================================================
# Functions
# ============================================================================

print_header() {
    echo ""
    echo "============================================================"
    echo "$1"
    echo "============================================================"
    echo ""
}

print_info() {
    echo "[INFO] $1"
}

print_ok() {
    echo "[OK]   $1"
}

print_error() {
    echo "[ERROR] $1" >&2
}

print_usage() {
    cat << EOF
Usage: bash setup.sh [OPTIONS]

Options:
  --all                     Build all bundles (default)
  --bundle NAME             Build only this bundle (e.g., legal, finance)
  --skill BUNDLE/SKILL      Build specific skill (e.g., legal/contract-review)
  --base-model MODEL        Use this Ollama base model (default: llama3.2)
  --dry-run                 Preview without building
  --help                    Show this help message

Examples:
  bash setup.sh --all
  bash setup.sh --bundle legal
  bash setup.sh --skill legal/contract-review
  bash setup.sh --base-model mistral --all
  bash setup.sh --dry-run

EOF
}

check_ollama() {
    if ! command -v ollama &> /dev/null; then
        print_error "Ollama is not installed or not in PATH"
        print_info "Install from: https://ollama.com"
        return 1
    fi
    print_ok "Ollama found: $(ollama --version)"
}

check_python() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed or not in PATH"
        return 1
    fi
    print_ok "Python 3 found: $(python3 --version)"
}

convert_skills() {
    print_info "Converting SKILL.md files to Modelfiles..."
    
    local cmd="python3 '$REPO_ROOT/convert.py' --base-model '$BASE_MODEL'"
    
    if [ -n "$BUNDLE_FILTER" ]; then
        cmd="$cmd --bundle '$BUNDLE_FILTER'"
    fi
    
    if [ "$DRY_RUN" = true ]; then
        cmd="$cmd --dry-run"
    fi
    
    if eval "$cmd"; then
        print_ok "Conversion complete"
    else
        print_error "Conversion failed"
        return 1
    fi
}

build_models() {
    if [ "$DRY_RUN" = true ]; then
        print_info "Dry run enabled, skipping model build"
        return 0
    fi
    
    local models_dir="$REPO_ROOT/models"
    
    if [ ! -d "$models_dir" ]; then
        print_error "models/ directory not found"
        return 1
    fi
    
    print_info "Building Ollama models..."
    
    local total=0
    local built=0
    
    # If building specific skill
    if [ -n "$SKILL_FILTER" ]; then
        local bundle_name="${SKILL_FILTER%/*}"
        local skill_name="${SKILL_FILTER#*/}"
        local modelfile="$models_dir/$bundle_name/$skill_name/Modelfile"
        
        if [ ! -f "$modelfile" ]; then
            print_error "Modelfile not found: $modelfile"
            return 1
        fi
        
        local model_name="skills-$(echo "$bundle_name" | tr '_' '-')-$(echo "$skill_name" | tr '_' '-')"
        print_info "Building: $model_name"
        
        if ollama create "$model_name" -f "$modelfile"; then
            print_ok "Built: $model_name"
            ((built++))
        else
            print_error "Failed to build: $model_name"
        fi
        ((total++))
    else
        # Find all Modelfiles
        while IFS= read -r modelfile; do
            local bundle_path=$(dirname "$(dirname "$modelfile")")
            local bundle_name=$(basename "$bundle_path")
            local skill_dir=$(basename "$(dirname "$modelfile")")
            local model_name="skills-$(echo "$bundle_name" | tr '_' '-')-$(echo "$skill_dir" | tr '_' '-')"
            
            print_info "Building: $model_name"
            
            if ollama create "$model_name" -f "$modelfile"; then
                print_ok "Built: $model_name"
                ((built++))
            else
                print_error "Failed to build: $model_name"
            fi
            ((total++))
        done < <(find "$models_dir" -name "Modelfile" -type f)
    fi
    
    print_info "Build summary: $built/$total models built successfully"
    
    if [ "$built" -eq "$total" ]; then
        return 0
    else
        return 1
    fi
}

list_models() {
    print_info "Installed Ollama models:"
    if ollama list | grep -q "^skills-"; then
        ollama list | grep "^skills-"
    else
        print_info "No skills models found"
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_header "Ollama Skills Library — Setup Script"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                shift
                ;;
            --bundle)
                BUNDLE_FILTER="$2"
                shift 2
                ;;
            --skill)
                SKILL_FILTER="$2"
                shift 2
                ;;
            --base-model)
                BASE_MODEL="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                print_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
    
    # Display config
    echo "Configuration:"
    echo "  Base model      : $BASE_MODEL"
    echo "  Bundle filter   : ${BUNDLE_FILTER:-(all)}"
    echo "  Skill filter    : ${SKILL_FILTER:-(all)}"
    echo "  Dry run         : $DRY_RUN"
    echo ""
    
    # Checks
    check_python || exit 1
    check_ollama || exit 1
    
    # Convert
    convert_skills || exit 1
    
    # Build
    build_models || exit 1
    
    # List
    echo ""
    list_models
    
    print_header "Setup Complete"
    print_ok "All done! Run: ollama run skills-<bundle>-<skill>"
    
    return 0
}

main "$@"
