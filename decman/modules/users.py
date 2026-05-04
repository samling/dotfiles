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
    BASELINE_GROUPS: tuple[str, ...] = (
        "audio",
        "input",
        "video",
        "wheel",
    )

    def __init__(
        self,
        extra_groups: tuple[str, ...] = (),
        managed_groups: tuple[str, ...] = (),
    ):
        super().__init__()

        for g in managed_groups:
            self.add_group(Group(groupname=g, system=True))

        self.add_user(
            User(
                username="sboynton",
                shell="/usr/bin/zsh",
            )
        )
        for g in self.BASELINE_GROUPS + tuple(extra_groups):
            self.add_user_to_group("sboynton", g)

        self.add_user(
            User(
                username=AUR_BUILDER_USER,
                home=AUR_BUILDER_HOME,
                system=True,
            )
        )
