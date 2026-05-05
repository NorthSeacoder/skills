#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY="$ROOT_DIR/registry/skills.yaml"

python3 - "$ROOT_DIR" "$REGISTRY" <<'PY'
import os
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
registry = Path(sys.argv[2]).resolve()

targets = [
    Path("~/.agents/skills").expanduser(),
    Path("~/.claude/skills").expanduser(),
    Path("~/.cursor/skills").expanduser(),
]

try:
    import yaml
except ImportError:
    print("PyYAML is required to unpublish links.", file=sys.stderr)
    sys.exit(1)

data = yaml.safe_load(registry.read_text()) or {}
skills = data.get("skills") or []

removed = []

for skill in skills:
    name = skill["name"]
    source_path = (root / skill["path"]).resolve()
    for target_dir in targets:
        target_path = target_dir / name
        if target_path.is_symlink() and target_path.resolve() == source_path:
            target_path.unlink()
            removed.append(str(target_path))

if removed:
    print("Removed links:")
    for item in removed:
        print(f"- {item}")
else:
    print("No managed links removed.")
PY
