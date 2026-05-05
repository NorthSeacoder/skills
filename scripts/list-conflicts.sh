#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY="$ROOT_DIR/registry/skills.yaml"

python3 - "$ROOT_DIR" "$REGISTRY" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
registry = Path(sys.argv[2]).resolve()

targets = {
    "agents": Path("~/.agents/skills").expanduser(),
    "claude": Path("~/.claude/skills").expanduser(),
    "cursor": Path("~/.cursor/skills").expanduser(),
}

try:
    import yaml
except ImportError:
    print("PyYAML is required to list conflicts.", file=sys.stderr)
    sys.exit(1)

data = yaml.safe_load(registry.read_text()) or {}
skills = data.get("skills") or []

conflicts = []

for skill in skills:
    name = skill["name"]
    source_path = (root / skill["path"]).resolve()
    publish = skill.get("publish", {})
    for target_name, enabled in publish.items():
        if not enabled or target_name not in targets:
            continue
        target_path = targets[target_name] / name
        if target_path.exists() or target_path.is_symlink():
            if not target_path.is_symlink():
                conflicts.append(f"{target_name}: {name} -> existing non-symlink")
            elif target_path.resolve() != source_path:
                conflicts.append(
                    f"{target_name}: {name} -> symlink points elsewhere ({target_path.resolve()})"
                )

if conflicts:
    print("Conflicts:")
    for item in conflicts:
        print(f"- {item}")
else:
    print("No conflicts.")
PY
