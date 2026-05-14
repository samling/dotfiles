# Codex Config MCP Merge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `dot_codex/modify_private_config.toml` idempotently merge the Serena MCP server into `~/.codex/config.toml` while preserving existing Codex config state and private file mode.

**Architecture:** Use chezmoi's modify-template mechanism so the file is interpreted as a template rather than executed as a plain script. The template parses existing TOML from `.chezmoi.stdin`, sets only `mcp_servers.serena`, and emits the complete merged TOML. Use the `modify_private_` source prefix so chezmoi keeps the target at mode `0600`.

**Tech Stack:** chezmoi v2 template functions, TOML, Git.

---

### File Structure

- Create: `modify_private_config.toml`
  - Responsibility: modify-template source for `~/.codex/config.toml`.
  - It reads existing TOML from stdin, merges the desired MCP server table, writes TOML, and keeps the target private.
- Delete: `modify_config.toml`
  - Responsibility: modify-template source for `~/.codex/config.toml`.
  - It is replaced because it maps to mode `0644`.
- Reference: `docs/superpowers/specs/2026-05-14-codex-config-mcp-merge-design.md`
  - Responsibility: approved design for this change.

### Task 1: Convert Static TOML To Private Modify Template

**Files:**
- Create: `modify_private_config.toml`
- Delete: `modify_config.toml`

- [ ] **Step 1: Replace the static file with a private chezmoi modify-template**

Delete `modify_config.toml` and create `modify_private_config.toml` with exactly:

```gotemplate
{{- /* chezmoi:modify-template */ -}}
{{- $config := dict -}}
{{- if .chezmoi.stdin -}}
{{-   $config = fromToml .chezmoi.stdin -}}
{{- end -}}

{{- $mcpServers := dict -}}
{{- if hasKey $config "mcp_servers" -}}
{{-   $mcpServers = get $config "mcp_servers" -}}
{{- end -}}
{{- $mcpServers = setValueAtPath "serena" (dict
  "startup_timeout_sec" 15
  "command" "serena"
  "args" (list "start-mcp-server" "--project-from-cwd" "--context=codex")
) $mcpServers -}}
{{- $config = setValueAtPath "mcp_servers" $mcpServers $config -}}
{{ $config | toToml }}
```

- [ ] **Step 2: Render the template against the current live config**

Run:

```bash
chezmoi execute-template --with-stdin --file modify_private_config.toml < /home/sboynton/.codex/config.toml
```

Expected: command exits 0 and the output includes the existing `projects`, `hooks`, and `plugins` tables plus:

```toml
[mcp_servers.serena]
  args = ["start-mcp-server", "--project-from-cwd", "--context=codex"]
  command = "serena"
  startup_timeout_sec = 15
```

- [ ] **Step 3: Verify the chezmoi target no longer fails as an executable**

Run:

```bash
chezmoi status --path-style absolute /home/sboynton/.codex/config.toml
```

Expected: command exits 0. The output may show `M /home/sboynton/.codex/config.toml` or equivalent because the source now wants to add the MCP server, but it must not contain `exec format error`.

- [ ] **Step 4: Review the file diff**

Run:

```bash
git diff -- modify_config.toml modify_private_config.toml
```

Expected: the source change replaces `modify_config.toml` with `modify_private_config.toml`, and the new file contains only the merge template.

- [ ] **Step 5: Commit the implementation**

Run:

```bash
git add modify_config.toml modify_private_config.toml
git commit -m "Merge Codex MCP config idempotently" -- modify_config.toml modify_private_config.toml
```

Expected: a commit containing the `chezmoi/dot_codex/modify_config.toml` removal and `chezmoi/dot_codex/modify_private_config.toml` addition.
