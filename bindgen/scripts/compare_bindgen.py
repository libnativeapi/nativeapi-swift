#!/usr/bin/env python3
from __future__ import annotations

import argparse
import difflib
import json
from pathlib import Path


def collect(dir_path: Path, ext: str) -> dict[str, Path]:
    return {p.name: p for p in dir_path.rglob(f"*{ext}")}


def analyze(existing: Path, generated: Path) -> dict:
    e_map = collect(existing, ".swift")
    g_map = collect(generated, ".swift")
    common = sorted(set(e_map) & set(g_map))
    report = {
        "existing_count": len(e_map),
        "generated_count": len(g_map),
        "common_count": len(common),
        "common": [],
    }
    for name in common:
        e_text = e_map[name].read_text(encoding="utf-8", errors="ignore").splitlines()
        g_text = g_map[name].read_text(encoding="utf-8", errors="ignore").splitlines()
        diff = list(difflib.unified_diff(e_text, g_text, n=0))
        g_raw = "\n".join(g_text)
        report["common"].append(
            {
                "file": name,
                "diff_lines": len(diff),
                "contains_any": "Any" in g_raw,
                "contains_native_call": "native_" in g_raw,
                "contains_singleton": "static let shared" in g_raw,
            }
        )
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--existing", required=True)
    parser.add_argument("--generated", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    result = analyze(Path(args.existing), Path(args.generated))
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
