# Codex Config MCP Merge Design

## Goal

Update the chezmoi source for `~/.codex/config.toml` so it idempotently merges the desired Codex MCP server configuration into an existing config file.

## Current State

`dot_codex/modify_config.toml` currently contains static TOML for `[mcp_servers.serena]`. Chezmoi treats `modify_config.toml` as a modify script for `~/.codex/config.toml`, so a plain TOML file fails with `exec format error` when chezmoi tries to execute it.

The live Codex config already contains unrelated local state such as trusted projects, hook hashes, model availability state, and enabled plugins. The update must preserve that state.

## Approach

Replace `modify_config.toml` with `modify_private_config.toml`, using a `chezmoi:modify-template`. The `modify_` attribute keeps the file as a merge operation, and the `private_` attribute keeps `~/.codex/config.toml` at mode `0600`.

The template will:

- Read `.chezmoi.stdin` when present.
- Parse existing TOML with `fromToml`.
- Ensure an `mcp_servers` table exists.
- Merge or overwrite the `serena` MCP server entry only.
- Emit the full merged TOML with `toToml`.

The desired server entry is:

```toml
[mcp_servers.serena]
startup_timeout_sec = 15
command = "serena"
args = ["start-mcp-server", "--project-from-cwd", "--context=codex"]
```

## Alternatives Considered

A standalone modify executable could parse and rewrite TOML, but that adds script dependencies and execution-mode concerns for a small merge.

Managing the entire Codex config as a normal template would be simpler to read, but it would risk overwriting user-local Codex state that should remain unmanaged.

## Testing

Validate the template by running it through `chezmoi execute-template --with-stdin` using the current `~/.codex/config.toml` as stdin and checking that:

- Existing top-level tables remain present.
- `[mcp_servers.serena]` is added with the expected values.
- Running `chezmoi status` for `~/.codex/config.toml` no longer fails with `exec format error`.
- `chezmoi diff` does not report a target mode change from `0600` to `0644`.
