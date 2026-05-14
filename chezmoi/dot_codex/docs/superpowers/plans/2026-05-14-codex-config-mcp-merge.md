# Codex Config MCP Merge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `dot_codex/modify_config.toml` idempotently merge the Serena MCP server into `~/.codex/config.toml` while preserving existing Codex config state.

**Architecture:** Use chezmoi's modify-template mechanism so the file is interpreted as a template rather than executed as a plain script. The template parses existing TOML from `.chezmoi.stdin`, sets only `mcp_servers.serena`, and emits the complete merged TOML.

**Tech Stack:** chezmoi v2 template functions, TOML, Git.

---

### File Structure

- Modify: `modify_config.toml`
  - Responsibility: modify-template source for `~/.codex/config.toml`.
  - It reads existing TOML from stdin, merges the desired MCP server table, and writes TOML.
- Reference: `docs/superpowers/specs/2026-05-14-codex-config-mcp-merge-design.md`
  - Responsibility: approved design for this change.

### Task 1: Convert Static TOML To Modify Template

**Files:**
- Modify: `modify_config.toml`

- [ ] **Step 1: Replace the file contents with a chezmoi modify-template**

Set `modify_config.toml` to exactly:

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
chezmoi execute-template --with-stdin --file modify_config.toml < /home/sboynton/.codex/config.toml
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
git diff -- modify_config.toml
```

Expected: the only source change in `modify_config.toml` is the conversion from static TOML to the merge template.

- [ ] **Step 5: Commit the implementation**

Run:

```bash
git add modify_config.toml
git commit -m "Merge Codex MCP config idempotently" -- modify_config.toml
```

Expected: a commit containing only `chezmoi/dot_codex/modify_config.toml`.
