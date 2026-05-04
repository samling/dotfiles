### Notes

- `vim.g.python3_host_prog = "~/.pyenv/shims/python"` improved startup times by at least an order of magnitude (~4s down to ~200ms)
- `pip install pynvim` may need to be run for different pyenv versions to ensure maximum compatibility

### Profiling

Check startup time via `vim-startuptime` with `:StartupTime`
    - This gives the same output as Lazy's profiler; it does not give the complete picture outside the scope of nvim itself.

Profile startup times manually by using `nvim --startuptime <logfile> <filename>`
    - This captures system events as well.

Optionally set the following env vars to automatically add `--startuptime` and log output:
    - `NVIM_PROFILE=true` - Enables profiling on startup to a temporary file; prints output and removes file on exit
    - `NVIM_PROFILE_SAVE_ON_EXIT=true` - Suppresses output on exit and saves the log file to `/tmp/nvim-profile.log`
