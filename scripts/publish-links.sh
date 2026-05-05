#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY="$ROOT_DIR/registry/skills.yaml"

TARGET_AGENTS="$HOME/.agents/skills"
TARGET_CLAUDE="$HOME/.claude/skills"
TARGET_CURSOR="$HOME/.cursor/skills"

mkdir -p "$TARGET_AGENTS" "$TARGET_CLAUDE"

python3 - "$ROOT_DIR" "$REGISTRY" "$TARGET_AGENTS" "$TARGET_CLAUDE" "$TARGET_CURSOR" <<'PY'
import os
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
registry = Path(sys.argv[2]).resolve()
targets = {
    "agents": Path(sys.argv[3]).expanduser(),
    "claude": Path(sys.argv[4]).expanduser(),
    "cursor": Path(sys.argv[5]).expanduser(),
}

try:
    import yaml
except ImportError:
    print("PyYAML is required to publish links.", file=sys.stderr)
    sys.exit(1)

data = yaml.safe_load(registry.read_text()) or {}
skills = data.get("skills") or []

errors = []
published = []

for skill in skills:
    name = skill["name"]
    source_path = (root / skill["path"]).resolve()
    publish = skill.get("publish", {})

    if not source_path.exists():
        errors.append(f"{name}: source path missing: {source_path}")
        continue

    for target_name, enabled in publish.items():
        if not enabled:
            continue
        if target_name not in targets:
            errors.append(f"{name}: unknown publish target: {target_name}")
            continue

        target_dir = targets[target_name]
        target_dir.mkdir(parents=True, exist_ok=True)
        target_path = target_dir / name

        if target_path.exists() or target_path.is_symlink():
            if not target_path.is_symlink():
                errors.append(f"{name}: {target_path} exists and is not a symlink")
                continue
            resolved = target_path.resolve()
            if resolved != source_path:
                errors.append(
                    f"{name}: {target_path} points to {resolved}, expected {source_path}"
                )
                continue
        else:
            os.symlink(str(source_path), str(target_path))
            published.append(f"{target_name}: {name}")

if errors:
    print("Publish failed:", file=sys.stderr)
    for error in errors:
        print(f"- {error}", file=sys.stderr)
    sys.exit(1)

if published:
    print("Published links:")
    for item in published:
        print(f"- {item}")
else:
    print("No links published.")
PY
