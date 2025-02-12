### Notes

- `vim.g.python3_host_prog = "~/.pyenv/shims/python"` improved startup times by at least an order of magnitude (~4s down to ~200ms)
- `pip install pynvim` may need to be run for different pyenv versions to ensure maximum compatibility

### Profiling

Profile startup times by using `nvim --startuptime <logfile> <filename>`
