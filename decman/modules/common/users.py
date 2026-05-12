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
    """Manage sboynton's account + the AUR builduser.

    Group membership for sboynton is applied additively in
    `after_update`, so the relevant package (which provides the group
    via systemd-sysusers or PKGBUILD .install) is already present by
    then.

    The aurbuilder system user exists so AUR builds with
    validpgpkeys can run as a real user with a writable home for the
    gpg keyring (decman's default `nobody` has /var/empty, which
    isn't writable). AurKeysModule populates the keyring; source.py
    points decman.aur.makepkg_user at this user.

    Args:
        extra_groups: supplementary groups for sboynton beyond the
            baseline. The group must already exist when after_update
            runs (typically because a package installed in the same
            run created it).
        managed_groups: groups decman itself should ensure exist. Use
            this for groups not created by any package - e.g. `keyd`,
            which the upstream PKGBUILD doesn't create but keyd.service
            wants to drop privileges into. Removing one from this set
            later causes decman to `groupdel` it, which can orphan
            files owned by package-installed daemons. Don't list groups
            that ship with a package here; use `ensured_groups` instead.
        ensured_groups: groups to create with `groupadd --system` if
            missing, without registering them as decman-managed. Used
            for the chicken-and-egg case on first bootstrap: the
            package that normally creates the group (docker, libvirt,
            wireshark-cli, qemu-base for kvm, ...) hasn't been
            installed yet at the time UserManager's before_update
            runs, so `usermod --groups docker` would fail. Removing
            a name from `ensured_groups` later is a no-op (decman
            doesn't track it), so files stay owned by whatever GID
            the package's sysusers/install script settled on.
    """

    # Arch's NetworkManager uses polkit for authorization; there's no
    # `networkmanager` group (that's a NixOS/Debian convention).
    #
    # `audio`, `input`, and `video` are intentionally NOT included
    # despite being part of the NixOS baseline. On Arch with
    # systemd-logind, the active session user gets per-device ACLs
    # (uaccess) on /dev/snd/*, /dev/input/event*, and /dev/dri/*
    # automatically. Static membership in those groups gives blanket
    # cross-session RW access, which (a) is unnecessary, and (b) breaks
    # apps like Parsec/libmatoya that rely on permission-based
    # heuristics to distinguish gamepads from touchpads/mice. See
    # snowcone-ltd/libmatoya#80.
    BASELINE_GROUPS: tuple[str, ...] = ("wheel",)

    def __init__(
        self,
        extra_groups: tuple[str, ...] = (),
        managed_groups: tuple[str, ...] = (),
        ensured_groups: tuple[str, ...] = (),
    ):
        super().__init__()

        self._ensured_groups = tuple(ensured_groups)

        for g in managed_groups:
            self.add_group(Group(groupname=g, system=True))

        # Pass groups to User() as well as add_user_to_group(): decman's
        # _ensure_user_matches treats User.groups=() (the default) as
        # "supplementary groups should be empty" and runs
        # `usermod -r --groups <existing>` in before_update, stripping
        # all current memberships. after_update then fails to restore
        # them because its store-vs-declared diff sees no change.
        # Setting groups here makes before_update a no-op; the
        # add_user_to_group calls keep after_update's bookkeeping in
        # sync so drift still gets reconciled.
        all_groups = self.BASELINE_GROUPS + tuple(extra_groups)
        self.add_user(
            User(
                username="sboynton",
                shell="/usr/bin/zsh",
                groups=all_groups,
            )
        )
        for g in all_groups:
            self.add_user_to_group("sboynton", g)

        self.add_user(
            User(
                username=AUR_BUILDER_USER,
                home=AUR_BUILDER_HOME,
                system=True,
            )
        )

    def before_update(self, store):
        # Pre-create groups that a package will (later) install via
        # its own sysusers/.install. Done before UserManager runs
        # useradd/usermod, so `--groups docker,libvirt,...` doesn't
        # fail on a fresh host where those packages aren't installed
        # yet. Idempotent: `getent group` skips if present, and a
        # later sysusers file matching the same name is a no-op.
        for g in self._ensured_groups:
            try:
                grp.getgrnam(g)
            except KeyError:
                decman.prg(["groupadd", "--system", g], check=True)
        super().before_update(store)

    def after_update(self, store):
        # UserManager's own after_update reconciles group memberships;
        # run that first so a brand-new user lands in its groups before
        # we touch lingering. Then enable linger so user systemd units
        # (awww, clipse-watch, quickshell, swayidle, ...) start at boot
        # and survive logout. enable-linger is idempotent.
        super().after_update(store)
        decman.prg(
            ["loginctl", "enable-linger", "sboynton"],
            check=False,
        )
