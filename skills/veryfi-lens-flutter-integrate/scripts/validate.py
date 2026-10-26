#!/usr/bin/env python3
"""Validate that this skill folder is internally linked and standalone."""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "SKILL.md",
    "install.md",
    "syntax.md",
    "platforms.md",
    "implementation.md",
    "recipes.md",
    "settings-groups.md",
    "settings-catalog.md",
    "conflicts.md",
    "clarifications.md",
    "troubleshooting.md",
    "parity.md",
    "unbridged.md",
    "sources.md",
    "templates/full.md",
    "templates/receipts.md",
    "templates/long-receipts.md",
    "templates/checks.md",
    "templates/credit-cards.md",
    "templates/business-cards.md",
    "templates/barcodes.md",
    "templates/ocr-code-strips.md",
    "templates/ocr-code-caps.md",
    "templates/w2.md",
    "templates/w9.md",
    "templates/any-documents.md",
]

import re

LINK = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
errors = []

for name in REQUIRED:
    if not (ROOT / name).is_file():
        errors.append(f"missing {name}")

skill = (ROOT / "SKILL.md").read_text()
if not skill.startswith("---\n"):
    errors.append("SKILL.md missing frontmatter")
front = skill.split("---", 2)[1]
if "name: veryfi-lens-flutter-integrate" not in front:
    errors.append("unexpected skill name")
body_lines = skill.split("---", 2)[2].count("\n")
if body_lines > 500:
    errors.append(f"SKILL.md body has {body_lines} lines")

for path in ROOT.rglob("*.md"):
    text = path.read_text()
    for match in LINK.finditer(text):
        target = match.group(1).strip()
        if target.startswith("http://") or target.startswith("https://") or target.startswith("mailto:"):
            continue
        if "#" in target:
            target = target.split("#", 1)[0]
        if not target:
            continue
        if target.startswith("/"):
            errors.append(f"{path.relative_to(ROOT)}: absolute link {target}")
            continue
        resolved = (path.parent / target).resolve()
        root = ROOT.resolve()
        if resolved != root and root not in resolved.parents:
            errors.append(f"{path.relative_to(ROOT)}: link leaves folder {target}")
        elif not resolved.exists():
            errors.append(f"{path.relative_to(ROOT)}: broken link {target}")

needles = [
    "imageSourceData",
    "imageSourceTag",
    "LensEvent",
    "initLens",
    "unawaited",
    "backupDocsToGallery",
    "VeryfiInfoView",
    "clearLensStorage",
    "307c6bc6f18b502d9bec45289517099da581dc0c",
    "sdk_binary_sizes",
    "credit_card",
]
# Success paths never call result. Awaiting these futures stays pending.
PENDING_METHODS = (
    "initLens",
    "showCamera",
    "retryPackage",
    "retryAllPackages",
    "discardPackage",
    "discardAllPackages",
    "shareOCRFeedback",
    "observeAnalyticsEvents",
)
AWAIT_PENDING = re.compile(
    r"await\s+Veryfi\s*\.\s*(?:" + "|".join(PENDING_METHODS) + r")\b"
)
blob = "\n".join(p.read_text() for p in ROOT.rglob("*.md"))
for needle in needles:
    if needle not in blob:
        errors.append(f"missing required text: {needle}")
if "cordova.plugins" in blob:
    errors.append("cordova.plugins leaked into the Flutter skill")
if "launchCallbackID" in blob:
    errors.append("Cordova launchCallbackID leaked into the Flutter skill")
for path in ROOT.rglob("*.md"):
    text = path.read_text()
    for match in AWAIT_PENDING.finditer(text):
        errors.append(
            f"{path.relative_to(ROOT)}: pending future awaited: {match.group(0)}"
        )

if errors:
    print("\n".join(errors))
    sys.exit(1)
print(f"OK {ROOT.name}: {len(list(ROOT.rglob('*.md')))} markdown files")
