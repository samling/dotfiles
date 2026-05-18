import pwd

import decman


def _systemctl_user(user, args):
    uid = pwd.getpwnam(user).pw_uid
    decman.prg(
        ["systemctl", "--user", *args],
        user=user,
        mimic_login=True,
        env_overrides={"XDG_RUNTIME_DIR": f"/run/user/{uid}"},
        check=False,
    )


def reconcile_units(module, store):
    """Stop newly-undeclared units and start currently-declared ones.

    Snapshots the module's unit set in the decman store so subsequent runs
    can diff against the previous declaration. Idempotent on already-running
    or already-stopped units.
    """
    sys_units = module.units() if hasattr(module, "units") else set()
    user_units = module.user_units() if hasattr(module, "user_units") else {}

    key = f"_units_last_seen_{module.name}"
    store.ensure(key, {"sys": [], "user": {}})
    prev = store[key]
    prev_sys = set(prev["sys"])
    prev_user = {u: set(s) for u, s in prev["user"].items()}

    # Stop units that left the declaration.
    removed_sys = prev_sys - sys_units
    if removed_sys:
        decman.prg(["systemctl", "stop", *sorted(removed_sys)], check=False)
    for user, prev_units in prev_user.items():
        removed = prev_units - user_units.get(user, set())
        if removed:
            _systemctl_user(user, ["stop", *sorted(removed)])

    # Start currently-declared units.
    if sys_units:
        decman.prg(["systemctl", "start", *sorted(sys_units)], check=False)
    for user, units in user_units.items():
        if units:
            _systemctl_user(user, ["start", *sorted(units)])

    # Snapshot for next run.
    store[key] = {
        "sys": sorted(sys_units),
        "user": {u: sorted(s) for u, s in user_units.items()},
    }
