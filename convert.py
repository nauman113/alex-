#!/usr/bin/env python3
from __future__ import annotations
"""
Ollama Skills Library — Conversion Script
==========================================
Converts all SKILL.md files (Claude Code format) to Ollama Modelfiles.

Usage:
    python convert.py
    python convert.py --base-model mistral
    python convert.py --dry-run
    python convert.py --bundle legal
"""

import os
import re
import json
import shutil
import argparse
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).parent
BUNDLES_DIR = REPO_ROOT / "bundles"
MODELS_DIR = REPO_ROOT / "models"
MARKETPLACE_JSON = REPO_ROOT / "marketplace.json"
LIBRARY_JSON = REPO_ROOT / "library.json"

# Temperature per bundle category
TEMPERATURE_MAP = {
    "legal": 0.3,
    "finance": 0.3,
    "engineering": 0.4,
    "data": 0.4,
    "analytics": 0.4,
    "delivery": 0.4,
    "research": 0.4,
    "operations": 0.4,
    "hr": 0.5,
    "pm-essentials": 0.5,
    "pm-engineering": 0.5,
    "agile": 0.5,
    "strategy": 0.5,
    "consulting": 0.5,
    "healthcare": 0.4,
    "education": 0.6,
    "sales": 0.6,
    "design": 0.6,
    "leadership": 0.6,
    "startup": 0.6,
    "marketing": 0.7,
    "communications": 0.7,
}

# Domain description per bundle (for SYSTEM prompt prefix)
DOMAIN_MAP = {
    "pm-essentials": "product management",
    "pm-engineering": "engineering-facing product management",
    "legal": "legal document analysis",
    "finance": "financial planning and analysis",
    "marketing": "marketing strategy and content",
    "design": "UX and product design",
    "hr": "human resources",
    "sales": "sales strategy and communication",
    "operations": "business operations",
    "data": "data management and analytics",
    "research": "research methodology",
    "strategy": "business strategy",
    "analytics": "product and business analytics",
    "delivery": "project delivery and management",
    "engineering": "software engineering documentation",
    "healthcare": "healthcare communication",
    "education": "education and curriculum design",
    "leadership": "leadership and executive communication",
    "communications": "corporate communications",
    "consulting": "management consulting",
    "startup": "startup strategy and fundraising",
    "agile": "agile delivery and scrum",
}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def parse_frontmatter(text: str) -> tuple[dict, str]:
    """Return (frontmatter_dict, body_text) from a SKILL.md string."""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, text

    end = None
    for i, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            end = i
            break

    if end is None:
        return {}, text

    fm_lines = lines[1:end]
    body = "\n".join(lines[end + 1:]).strip()

    fm = {}
    for line in fm_lines:
        if ":" in line:
            key, _, val = line.partition(":")
            fm[key.strip()] = val.strip().strip('"').strip("'")

    return fm, body


def remove_trigger_phrases(body: str) -> str:
    """Strip the '## Example Trigger Phrases' section from body."""
    pattern = r"\n## Example Trigger Phrases\b.*?(?=\n## |\Z)"
    cleaned = re.sub(pattern, "", body, flags=re.DOTALL)
    return cleaned.strip()


def escape_system_prompt(text: str) -> str:
    """Escape triple-quotes inside SYSTEM prompt body."""
    return text.replace('"""', "'''")


def build_modelfile(bundle: str, fm: dict, body: str, base_model: str) -> str:
    """Generate the full Modelfile content."""
    name = fm.get("name", "Skill")
    description = fm.get("description", "")
    version = fm.get("version", "1.0.0")
    tags = fm.get("tags", "")
    temperature = TEMPERATURE_MAP.get(bundle, 0.5)
    domain = DOMAIN_MAP.get(bundle, bundle)

    body_clean = remove_trigger_phrases(body)
    body_escaped = escape_system_prompt(body_clean)

    system_prompt = f'You are a professional assistant specializing in {domain}. Follow the structured workflow below exactly when the user asks for help.\n\n{body_escaped}'

    modelfile = f"""# Ollama Skills Library — {bundle} / {name}
# Version: {version}
# Tags: {tags}
# Description: {description}

FROM {base_model}

PARAMETER temperature {temperature}
PARAMETER num_ctx 8192
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1

SYSTEM \"\"\"
{system_prompt}
\"\"\"
"""
    return modelfile


def slug(name: str) -> str:
    """Convert skill folder name to an Ollama model tag segment."""
    return re.sub(r"[^a-z0-9-]", "-", name.lower())


# ---------------------------------------------------------------------------
# Core conversion
# ---------------------------------------------------------------------------

def convert_skill(skill_dir: Path, models_bundle_dir: Path, bundle: str, base_model: str, dry_run: bool) -> "dict | None":
    """Convert one SKILL.md → Modelfile. Returns skill metadata or None."""
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        return None

    text = skill_md.read_text(encoding="utf-8")
    fm, body = parse_frontmatter(text)

    if not fm.get("name"):
        print(f"  [WARN] Missing 'name' frontmatter in {skill_md}")
        return None

    modelfile_content = build_modelfile(bundle, fm, body, base_model)

    skill_slug = slug(skill_dir.name)
    out_skill_dir = models_bundle_dir / skill_dir.name

    if not dry_run:
        out_skill_dir.mkdir(parents=True, exist_ok=True)
        (out_skill_dir / "Modelfile").write_text(modelfile_content, encoding="utf-8")

    model_name = f"skills-{slug(bundle)}-{skill_slug}"
    print(f"  [OK]  {skill_md.relative_to(REPO_ROOT)}  ->  {out_skill_dir.relative_to(REPO_ROOT)}/Modelfile  ({model_name})")

    return {
        "id": skill_dir.name,
        "name": fm.get("name", skill_dir.name),
        "description": fm.get("description", ""),
        "modelName": model_name,
        "path": str((out_skill_dir / "Modelfile").relative_to(REPO_ROOT)).replace("\\", "/"),
    }


def convert_bundle(bundle_dir: Path, base_model: str, dry_run: bool) -> "dict | None":
    """Convert one bundle directory. Returns bundle metadata."""
    bundle = bundle_dir.name
    plugin_json = bundle_dir / "plugin.json"

    # Read existing plugin.json for metadata
    meta = {}
    if plugin_json.exists():
        with open(plugin_json, encoding="utf-8") as f:
            meta = json.load(f)

    models_bundle_dir = MODELS_DIR / bundle
    if not dry_run:
        models_bundle_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n[Bundle] {bundle}")

    skills = []
    for skill_dir in sorted(bundle_dir.iterdir()):
        if skill_dir.is_dir():
            result = convert_skill(skill_dir, models_bundle_dir, bundle, base_model, dry_run)
            if result:
                skills.append(result)

    # Write manifest.json
    manifest = {
        "$schema": "https://ollama.com/skills/manifest.schema.json",
        "name": bundle,
        "displayName": meta.get("name", bundle),
        "version": meta.get("version", "1.0.0"),
        "description": meta.get("description", ""),
        "keywords": meta.get("keywords", []),
        "author": {
            "name": "Ollama Skills Community",
            "url": "https://github.com/nauman113/alex-",
        },
        "license": "MIT",
        "skillCount": len(skills),
        "baseModel": base_model,
        "skills": skills,
    }

    if not dry_run:
        manifest_path = models_bundle_dir / "manifest.json"
        with open(manifest_path, "w", encoding="utf-8") as f:
            json.dump(manifest, f, indent=2)
        print(f"  [OK]  manifest.json written ({len(skills)} skills)")

    return {
        "id": bundle,
        "name": meta.get("name", bundle),
        "version": meta.get("version", "1.0.0"),
        "description": meta.get("description", ""),
        "category": meta.get("category", bundle),
        "keywords": meta.get("keywords", []),
        "skillCount": len(skills),
        "path": f"models/{bundle}",
        "manifestConfig": f"models/{bundle}/manifest.json",
        "baseModel": base_model,
    }


def build_library_json(bundles_meta: "list[dict]", base_model: str) -> dict:
    return {
        "$schema": "https://ollama.com/skills/library.schema.json",
        "name": "Ollama Skills Library",
        "version": "1.0.0",
        "description": (
            "A community library of structured skills for Ollama — professional domain expertise "
            "across product management, engineering, legal, finance, marketing, design, HR, sales, "
            "operations, data, research, strategy, analytics, delivery, healthcare, education, "
            "leadership, communications, consulting, startup, and agile."
        ),
        "homepage": "https://github.com/nauman113/alex-",
        "license": "MIT",
        "defaultBaseModel": base_model,
        "maintainer": {
            "name": "Ollama Skills Community",
            "email": "skills@ollama.local",
            "url": "https://github.com/nauman113/alex-",
        },
        "bundles": bundles_meta,
    }


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Convert Claude Code Skills Library to Ollama Modelfiles")
    parser.add_argument("--base-model", default="llama3.2", help="Ollama base model (default: llama3.2)")
    parser.add_argument("--bundle", default=None, help="Convert only this bundle")
    parser.add_argument("--dry-run", action="store_true", help="Preview without writing files")
    args = parser.parse_args()

    base_model = args.base_model
    dry_run = args.dry_run

    print("=" * 60)
    print("Ollama Skills Library — Conversion Script")
    print("=" * 60)
    print(f"  Base model : {base_model}")
    print(f"  Dry run    : {dry_run}")
    print(f"  Source     : {BUNDLES_DIR}")
    print(f"  Output     : {MODELS_DIR}")

    if not BUNDLES_DIR.exists():
        print(f"\n[ERROR] bundles/ directory not found at {BUNDLES_DIR}")
        return 1

    if not dry_run and MODELS_DIR.exists():
        print(f"\n[INFO] Removing existing models/ directory...")
        shutil.rmtree(MODELS_DIR)
    if not dry_run:
        MODELS_DIR.mkdir(parents=True, exist_ok=True)

    bundles_meta = []
    total_skills = 0
    total_bundles = 0

    for bundle_dir in sorted(BUNDLES_DIR.iterdir()):
        if not bundle_dir.is_dir():
            continue
        if args.bundle and bundle_dir.name != args.bundle:
            continue

        bundle_meta = convert_bundle(bundle_dir, base_model, dry_run)
        if bundle_meta:
            bundles_meta.append(bundle_meta)
            total_skills += bundle_meta["skillCount"]
            total_bundles += 1

    # Write library.json
    library = build_library_json(bundles_meta, base_model)
    if not dry_run:
        with open(LIBRARY_JSON, "w", encoding="utf-8") as f:
            json.dump(library, f, indent=2)
        print(f"\n[OK]  library.json written ({total_bundles} bundles, {total_skills} skills)")

    print("\n" + "=" * 60)
    print(f"Conversion complete: {total_bundles} bundles, {total_skills} skills")
    if dry_run:
        print("[DRY RUN] No files were written.")
    else:
        print(f"Output: {MODELS_DIR}")
        print(f"Next: bash setup.sh     (builds all Ollama models)")
    print("=" * 60)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
