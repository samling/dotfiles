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
            this for groups not created by any package — e.g. `keyd`,
            which the upstream PKGBUILD doesn't create but keyd.service
            wants to drop privileges into.
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
    ):
        super().__init__()

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
