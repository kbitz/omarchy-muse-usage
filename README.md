# Muse Usage for Omarchy

Adds a Muse tab to Omarchy's Agents panel (the bot in the bar), next to
Claude Code, Codex, and Cursor, with the same sections they have:

- **Limits**: how much of the plan's 5-hour and weekly subscription windows
  is used, with the time until each resets.
- **Tokens by day**: the last week, with today's prompt and session count on
  hover.
- **Tokens by model**: every model in the session logs, with the input,
  output, and cache split on hover.

## Install

```bash
omarchy plugin add https://github.com/kbitz/omarchy-muse-usage.git --enable
```

The service collects once when enabled, then every five minutes. The Agents
panel picks up the resulting record; opening the panel does not force a new
Muse collection. The tab needs local usage or limits to show.

## Updates

```bash
omarchy plugin update kbitz.muse-usage
```

Omarchy fetches this repository's default branch, shows the changes for
approval, fast-forwards the installed clone, validates it, and reloads the
plugin. Run the command without an ID to update all git-managed plugins.
Keep the installed clone free of local edits so it can fast-forward.

The plugin version lives in `manifest.json` and follows semantic versioning:
patch releases fix bugs, minor releases add compatible features, and major
releases make breaking changes. Updates follow `main`, not version tags;
the manifest version identifies the installed release.

## How it works

The Agents panel draws every JSON record in
`~/.local/state/omarchy/agents/usage/`. This plugin is a small service that
runs `muse-usage` every five minutes, and that script writes `muse.json`
there in the same format the built-in Claude and Codex collectors use.

Limits come from Meta's account API, the way
[CodexBar](https://github.com/steipete/CodexBar) reads them: the script
posts to `https://api.meta.ai/muse-code/key` with the device-code token
`muse login` keeps in `~/.config/muse/auth.json`, and the response carries
the plan name and the 5-hour and weekly windows. The plugin never refreshes
or stores credentials, and the inference key that response mints is
discarded, never written anywhere; sign in with `muse login`. Meta omits
the windows while the 5-hour one is idle, so the last good limits are
cached in `~/.cache/omarchy/agent-usage/muse-usage.json` and stay on the
tab until they reset. The cache also records the auth file's modification
time, so changing the saved sign-in invalidates old account limits. On a
first run while idle, limits stay absent until Meta returns them; the plugin
does not read browser cookies for a fallback.

Tokens come from this machine only. Each Muse session keeps a JSONL event
stream in `~/.local/share/muse/sessions/`, and every finished model call
lands there as a `model_completed` record with the model and its token
usage. Automated reviews (`automated_review_completed`) count too; goal
attribution records repeat those numbers and are ignored. Each finished
inference record is one prompt — the way the Claude collector counts
assistant usage messages — and its stream is the session, subagent sessions
included. Every run recounts the logs, so the history is only ever as
complete as the session logs that are still on disk.

One reading note: Muse's `input_tokens` is the whole prompt, cache
included, unlike the convention the other collectors read. The script
reports the uncached remainder as input and lets the cache fields carry the
rest, so the four numbers on hover add up without counting the cache twice.

Run `./muse-usage --print` to see the record without writing `muse.json`.
It still queries limits and updates their cache.

## When Omarchy adds Muse itself

If an Omarchy update ever puts `omarchy-agent-usage-muse` on your system,
that collector writes the same `muse.json`, so this plugin stops writing the
record and stops deleting it on removal. The built-in version takes over,
and you can remove this plugin whenever you like.

Until then the tab uses the panel's default glyph: the panel only loads
marks from its own built-in folder, and Omarchy ships no Muse mark yet.

## Hide or remove

```bash
omarchy plugin disable kbitz.muse-usage
omarchy plugin remove kbitz.muse-usage
```

Either one deletes `muse.json`, so the Muse tab disappears with it.
Reloading the service also removes the old record until collection finishes.
