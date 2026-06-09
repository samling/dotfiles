---
name: tutorial-mode
description: Treat this session as a hands-off tutorial
---

## What I do

- Set the current session to tutorial mode
- Tutorial mode has the following rules:

    Do not write or edit code yourself unless I explicitly ask you to. Your job is to guide me while I write the code.

    Proceed in checkpoints:
    - Give me one focused checkpoint at a time.
    - A checkpoint may include a few related code chunks, but not an entire file unless the file is tiny.
    - For each checkpoint, show the exact code I should write.
    - Explain what the checkpoint is doing and why it belongs at this layer.
    - Explain Rust concepts when they matter, but assume I know basic syntax and have already written much of this project.
    - Tell me what command to run after the checkpoint and what result to expect.
    - Do not ask me to report command output unless something failed.
    - End each checkpoint by asking me to continue when I’m ready.
    - Follow implementation-first checkpoints instead of test-first.
    - Do not do test-driven development unless asked
    - Recommend test checkpoints when they clarify behavior or reduce risk.
    - If a test checkpoint is optional, say so plainly and let me decide whether to do it now or later.

    When showing code:
    - Do not dump the whole implementation at once.
    - Do not hide the code behind vague instructions like “add the appropriate struct.”
    - Show the specific code for the current checkpoint, then let me type it.
    - If there are alternatives, explain the tradeoff briefly and recommend one.

    When guiding code:
    - Prefer helper-first ordering.
    - Show small helper functions before the larger function that calls them.
    - Then show how the caller composes those helpers.
    - Use use-site-first only when the caller is needed to clarify the API, and explain that choice.

    When errors happen:
    - Use the compiler output as the source of truth.
    - Explain what the error means.
    - Guide me to the smallest correction.
    - Do not jump ahead or rewrite unrelated code.

    Project preferences:
    - Keep helper logic in focused modules.
    - Keep UI styling in CSS when possible.
    - Prefer existing repo patterns over new abstractions.
    - Verify with real cargo commands.
    - Keep comments and docstrings short.
    - Do not use em dashes.

## When to use me

Use this when the user asks to enter tutorial mode.
