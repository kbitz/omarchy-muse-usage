# Muse Usage for Omarchy

Adds a Muse tab to Omarchy's Agents panel (the bot in the bar), next to
Claude Code, Codex, and Cursor.

Work in progress. See the sibling
[omarchy-cursor-usage](https://github.com/kbitz/omarchy-cursor-usage) plugin
for the pattern this follows: a small service that periodically writes a
usage record to `~/.local/state/omarchy/agents/usage/`, which the Agents
panel draws without changes.
