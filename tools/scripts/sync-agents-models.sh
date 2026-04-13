#!/usr/bin/env bash
# Sync check — verify AGENTS.md and models.yaml agree on primary model assignments
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AGENTS_MD="$ROOT/AGENTS.md"
MODELS_YAML="$ROOT/config/models.yaml"

echo "=== Checking AGENTS.md vs models.yaml sync ==="
echo ""

ERRORS=0

# Extract agent names and primary models from models.yaml
python3 -c "
import yaml, re, sys

with open('$MODELS_YAML') as f:
    config = yaml.safe_load(f)

with open('$AGENTS_MD') as f:
    agents_md = f.read()

agents = config.get('agents', {})
issues = []

for name, conf in agents.items():
    yaml_model = conf.get('primary_model', '(not set)')

    # Check if agent has escalation and fallback on different providers
    esc = conf.get('escalation_model', '')
    fb = conf.get('fallback_model', '')
    if esc and fb:
        esc_provider = esc.split('/')[0] if '/' in esc else ''
        fb_provider = fb.split('/')[0] if '/' in fb else ''
        if esc_provider and fb_provider and esc_provider == fb_provider:
            issues.append(f'  WARN: {name} escalation and fallback use same provider: {esc_provider}')

    # Check if agent exists in AGENTS.md
    if name.upper() not in agents_md.upper() and name not in agents_md:
        issues.append(f'  MISSING: {name} in models.yaml but not found in AGENTS.md')

    # Check frontmatter in agent prompt file
    import os
    agent_file = os.path.join('$ROOT', 'agents', f'{name.lower()}.md')
    if os.path.exists(agent_file):
        with open(agent_file) as af:
            content = af.read()
        model_match = re.search(r'^model:\s*(.+)$', content, re.MULTILINE)
        if model_match:
            frontmatter_model = model_match.group(1).strip()
            if frontmatter_model != yaml_model:
                issues.append(f'  DRIFT: {name} — agents/{name.lower()}.md says \"{frontmatter_model}\" but models.yaml says \"{yaml_model}\"')

if issues:
    for i in issues:
        print(i)
    print(f'\n  {len(issues)} issue(s) found')
    sys.exit(1)
else:
    print('  All agents in sync')
    print(f'  Checked {len(agents)} agents')
" 2>&1

EXIT=$?
if [[ $EXIT -ne 0 ]]; then
  echo ""
  echo "Fix the issues above, then re-run this script."
fi
exit $EXIT
