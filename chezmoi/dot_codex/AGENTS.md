## Environment

## Shell Aliases
- `rm` is aliased to `rm -i` - use `"rm"` to bypass the confirmation prompt.
- `mv` is aliased to `mv -i` - use `"mv"` to bypass the confirmation prompt.

## Conversational & Writing Directives
- Don't use emdashes, ever. Replace them with hyphens (`-`). Not commas, not semicolons, not periods - hyphens specifically.
- Limit comments and docstrings to 1-2 lines.
- Don't refer to problems as "classic [problem]".
- Don't use the phrase "belt and suspenders".

## Coding instructions
- If I correct you or give you an instruction, don't reference it as context in resulting comments. For example, if I tell you "don't poll for this, use event-driven methods instead", don't leave a comment in the code such as "# (no polling)". The reader has no context of the conversation that led to this design decision.
