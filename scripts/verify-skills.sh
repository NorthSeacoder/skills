#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY="$ROOT_DIR/registry/skills.yaml"

python3 - "$ROOT_DIR" "$REGISTRY" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
registry = Path(sys.argv[2]).resolve()

try:
    import yaml
except ImportError:
    print("PyYAML is required to verify skills.", file=sys.stderr)
    sys.exit(1)

data = yaml.safe_load(registry.read_text()) or {}
skills = data.get("skills") or []
errors = []
seen = set()

valid_publish_keys = {"agents", "claude", "cursor"}
allowed_status = {"active", "experimental", "deprecated"}
allowed_owner = {"self", "adopted"}

for skill in skills:
    name = skill.get("name")
    path_value = skill.get("path")

    if not name:
        errors.append("registry entry missing name")
        continue
    if name in seen:
        errors.append(f"duplicate skill name: {name}")
    seen.add(name)

    if not re.fullmatch(r"[A-Za-z0-9._-]+", name):
        errors.append(f"{name}: invalid characters in name")

    if not path_value:
        errors.append(f"{name}: missing path")
        continue

    path = (root / path_value).resolve()
    skill_md = path / "SKILL.md"

    if not path.exists():
        errors.append(f"{name}: path missing: {path}")
    elif not skill_md.exists():
        errors.append(f"{name}: missing SKILL.md at {skill_md}")

    status = skill.get("status")
    if status not in allowed_status:
        errors.append(f"{name}: invalid status: {status}")

    owner = skill.get("owner")
    if owner not in allowed_owner:
        errors.append(f"{name}: invalid owner: {owner}")

    publish = skill.get("publish", {})
    if not isinstance(publish, dict):
        errors.append(f"{name}: publish must be a mapping")
    else:
        unknown_keys = set(publish) - valid_publish_keys
        if unknown_keys:
            errors.append(f"{name}: unknown publish keys: {sorted(unknown_keys)}")
        for key, value in publish.items():
            if not isinstance(value, bool):
                errors.append(f"{name}: publish.{key} must be boolean")

    if skill_md.exists():
        text = skill_md.read_text()
        refs = re.findall(r"\]\((?!https?://)(?!/)([^)#]+)\)", text)
        for ref in refs:
            ref_path = (path / ref).resolve()
            if not ref_path.exists():
                errors.append(f"{name}: missing relative reference target: {ref}")

skill_dirs = []
skills_root = root / "skills"
if skills_root.exists():
    for child in sorted(skills_root.iterdir()):
        if child.is_dir():
            skill_dirs.append(child.name)
            if not (child / "SKILL.md").exists():
                errors.append(f"unregistered or incomplete skill directory: {child} missing SKILL.md")

registered_paths = {Path(skill["path"]).parts[-1] for skill in skills if "path" in skill}
for skill_dir in skill_dirs:
    if skill_dir not in registered_paths:
        errors.append(f"skill directory not registered: skills/{skill_dir}")

if errors:
    print("Verification failed:", file=sys.stderr)
    for error in errors:
        print(f"- {error}", file=sys.stderr)
    sys.exit(1)

print("Verification passed.")
PY
