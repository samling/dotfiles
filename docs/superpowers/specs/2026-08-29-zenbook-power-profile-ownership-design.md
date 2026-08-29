# Zenbook Power Profile Ownership

## Problem

The Zenbook runs both `asusd` and `power-profiles-daemon`. Both services write
the ASUS ACPI platform profile and AMD P-state EPP values. Upstream `asusctl`
documents this as an unsupported configuration because the competing writes
can race, especially around power-source changes and suspend/resume.

The previous boot resumed normally at the kernel level but became sluggish
until reboot. No NVMe, thermal, GPU-resume, or kernel-lockup error accompanied
that incident. Removing the competing power-profile writer is the smallest
change that addresses the observed control-path fault.

## Design

`asusd` will be the sole power-profile owner on the `xen` Zenbook host.

- Keep the existing `asusd.ron` behavior: Quiet on battery, Balanced on AC,
  and `BalancePerformance` EPP for Quiet.
- Disable and mask `power-profiles-daemon.service` from `ZenbookModule` so it
  is stopped during deployment and cannot be restarted through D-Bus.
- Keep the PPD package in the shared graphical package set. Other hosts remain
  unaffected, and no host-specific package exclusion mechanism is introduced.
- Keep `asusd.service` managed by the existing Zenbook systemd unit set.

## Deployment

The Zenbook module will reconcile the PPD service before starting its declared
services. The operation must be idempotent so repeated Decman runs leave the
service masked without producing a configuration change.

## Verification

After applying the configuration:

- `power-profiles-daemon.service` is masked and inactive.
- `asusd.service` is active.
- On battery, the ACPI platform profile is `quiet` and every AMD P-state policy
  uses `balance_performance` EPP.
- After one suspend/resume cycle, those values remain unchanged and interactive
  performance does not enter the previously observed degraded state.

## Scope

This change does not alter fan curves, GPU power management, suspend mode,
kernel parameters, shared GUI packages, or power-profile behavior on any host
other than `xen`.
