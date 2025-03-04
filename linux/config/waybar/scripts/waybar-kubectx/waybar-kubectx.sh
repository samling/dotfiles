#!/usr/bin/env bash

CURRENT_CONTEXT="none"

kubectl_context () {
  if command -v kubectl >/dev/null 2>&1; then
    kubectl config current-context
  fi
}

CURRENT_CONTEXT=$(kubectl_context)

echo $CURRENT_CONTEXT
