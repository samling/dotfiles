import grp

import decman
from decman.extras.users import Group, User, UserManager

# Kept here (not in aur_keys.py) so UsersModule can create the user
# without importing aur_keys. AurKeysModule reads the same constants
# back via `from modules.users import AUR_BUILDER_*`.
AUR_BUILDER_USER = "aurbuilder"
AUR_BUILDER_HOME = "/var/lib/aurbuilder"
AUR_BUILDER_GNUPG_HOME = f"{AUR_BUILDER_HOME}/.gnupg"


class UsersModule(UserManager):
    """Manage sboynton + the AUR builduser.

    Modules can declare group requirements as class attributes; this
    module scans `decman.modules` in `before_update` and folds them
    into sboynton's supplementary groups:

        class FooModule(decman.Module):
            user_groups = ("foo",)            # sboynton needs `foo`
            managed_user_groups = ("foo",)    # decman should own it
            ensured_user_groups = ("foo",)    # pre-create via groupadd

    A host file is then just a flat module list - no UsersModule
    construction, no group plumbing - and a module like `KeydModule`
    carries its own user-group footprint.

    Args:
        extra_groups: baseline supplementary groups for sboynton.
            Set per role (gui: docker/kvm/libvirt/wireshark; wsl:
            docker/kvm/libvirt). Modules layered on top declare their
            own via `user_groups`.
        ensured_groups: groups to pre-create with `groupadd --system`
            if missing. Used for package-owned groups that aren't
            present until the package installs (docker, libvirt,
            wireshark, qemu's kvm). On a fresh host the package
            hasn't installed yet when useradd runs, so
            `--groups docker,...` would otherwise fail.
    """

    # `audio`, `input`, `video` deliberately omitted. systemd-logind
    # grants per-device uaccess to the active session user; static
    # membership is unnecessary and breaks Parsec/libmatoya gamepad
    # detection. See snowcone-ltd/libmatoya#80.
    BASELINE_GROUPS: tuple[str, ...] = ("wheel",)

    def __init__(
        self,
        extra_groups: tuple[str, ...] = (),
        ensured_groups: tuple[str, ...] = (),
    ):
        super().__init__()
        self._extra_groups = tuple(extra_groups)
        self._ensured_groups = tuple(ensured_groups)
        # AurBuilder is self-contained, no module discovery needed.
        self.add_user(
            User(
                username=AUR_BUILDER_USER,
                home=AUR_BUILDER_HOME,
                system=True,
            )
        )

    def _collect_module_requests(
        self,
    ) -> tuple[set[str], set[str], set[str]]:
        """Walks `decman.modules` for user_groups / managed_user_groups
        / ensured_user_groups class-or-instance attributes. Returns
        (extra-sboynton-groups, decman-managed-groups, pre-create-groups).
        """
        extra: set[str] = set()
        managed: set[str] = set()
        ensured: set[str] = set()
        for mod in decman.modules:
            extra.update(getattr(mod, "user_groups", ()) or ())
            managed.update(getattr(mod, "managed_user_groups", ()) or ())
            ensured.update(getattr(mod, "ensured_user_groups", ()) or ())
        return extra, managed, ensured

    def before_update(self, store):
        # Discover module-declared groups now that source.py has
        # finished registering everything.
        m_extra, m_managed, m_ensured = self._collect_module_requests()

        all_extra = tuple(self._extra_groups) + tuple(sorted(m_extra))
        all_ensured = set(self._ensured_groups) | m_ensured

        # Pre-create package-owned groups (idempotent).
        for g in sorted(all_ensured):
            try:
                grp.getgrnam(g)
            except KeyError:
                decman.prg(["groupadd", "--system", g], check=True)

        # Register decman-managed groups (those with no owning package).
        for g in m_managed:
            self.add_group(Group(groupname=g, system=True))

        # Now build sboynton with the final group set. Passing groups
        # to User() makes _ensure_user_matches a no-op when the live
        # set matches; add_user_to_group keeps after_update's diff in
        # sync so drift still reconciles.
        all_groups = self.BASELINE_GROUPS + all_extra
        self.add_user(
            User(
                username="sboynton",
                shell="/usr/bin/zsh",
                groups=all_groups,
            )
        )
        for g in all_groups:
            self.add_user_to_group("sboynton", g)

        super().before_update(store)

    def after_update(self, store):
        # UserManager's own after_update reconciles group memberships;
        # run that first so a brand-new user lands in its groups before
        # we touch lingering. Then enable linger so user systemd units
        # start at boot and survive logout. enable-linger is idempotent.
        super().after_update(store)
        decman.prg(
            ["loginctl", "enable-linger", "sboynton"],
            check=False,
        )
