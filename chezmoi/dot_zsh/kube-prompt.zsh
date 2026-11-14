# Cache pane/global context comparison outside Starship's command timeout.
# Unchanged prompts use only shell builtins and stat(2), never kubectl.
function _kube-prompt-refresh() {
  emulate -L zsh

  if [[ "${KUBECONFIG:-}" == "${KUBECONFIG_GLOBAL:-}" ]]; then
    unset STARSHIP_KUBE_PANE_CONTEXT _KUBE_PROMPT_SIGNATURE
    return 0
  fi

  local -a files signature modified
  local -A metadata seen
  local file pane_context global_context
  signature=("${KUBECONFIG:-}" "${KUBECONFIG_GLOBAL:-}")
  files=("${(@s.:.)${KUBECONFIG:-$HOME/.kube/config}}"
         "${(@s.:.)${KUBECONFIG_GLOBAL:-$HOME/.kube/config}}")
  for file in "${files[@]}"; do
    # Empty entries are ignored by kubectl; absolute paths also detect a cd
    # changing the meaning of a manually exported relative KUBECONFIG.
    [[ -n "$file" ]] || continue
    file=${file:a}
    [[ -z "${seen[$file]:-}" ]] || continue
    seen[$file]=1
    # Formatting the whole stat result resolves uid/gid names through NSS.
    # Format only mtime, avoiding potentially slow user/group lookups.
    if zstat -H metadata -- "$file" 2>/dev/null &&
       zstat -A modified -F '%s.%N' +mtime -- "$file" 2>/dev/null; then
      # Nanosecond timestamps catch rapid, same-size context switches.
      signature+=("$file" "${metadata[device]}" "${metadata[inode]}"
                  "${metadata[size]}" "${modified[1]}" "${metadata[ctime]}"
                  "${metadata[mode]}" "${metadata[uid]}" "${metadata[gid]}")
    else
      signature+=("$file" missing)
    fi
  done

  # Pane commands force a refresh after mutations, even on a metadata cache hit.
  if [[ "${1:-}" != --force &&
        "${_KUBE_PROMPT_SIGNATURE:-}" == "${(j: :)${(@q)signature}}" ]]; then
    return 0
  fi
  typeset -g _KUBE_PROMPT_SIGNATURE="${(j: :)${(@q)signature}}"
  unset STARSHIP_KUBE_PANE_CONTEXT

  # Cache failures too: an invalid config should not spawn kubectl on every
  # prompt. Editing it or changing KUBECONFIG invalidates the failed result.
  pane_context=$(command kubectl config current-context 2>/dev/null) || return 0
  global_context=$(KUBECONFIG="${KUBECONFIG_GLOBAL:-}" command kubectl config current-context 2>/dev/null)
  if [[ -n "$pane_context" && "$pane_context" != "$global_context" ]]; then
    export STARSHIP_KUBE_PANE_CONTEXT="$pane_context"
  fi
  return 0
}

# Never inherit another shell's cached pane indicator.
unset STARSHIP_KUBE_PANE_CONTEXT _KUBE_PROMPT_SIGNATURE
autoload -Uz add-zsh-hook
if zmodload -F zsh/stat b:zstat; then
  add-zsh-hook precmd _kube-prompt-refresh
fi
