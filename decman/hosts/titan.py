import decman

from roles.gui import MODULES

# CachyOS on bare metal. The default gui role covers the desktop
# stack; no LaptopModule / ZenbookModule (not portable hardware) and
# no EndeavourOSModule (CachyOS, not EOS).
#
# CachyOS-specific packages (cachyos-keyring, cachyos-mirrorlist,
# cachyos-v3-mirrorlist, cachyos-v4-mirrorlist, linux-cachyos,
# linux-cachyos-headers, cachyos-settings, ...) are intentionally
# NOT declared here yet. Add them as drift surfaces — e.g. when
# decman queues one for removal — so the declared set stays
# truthful instead of preemptively absorbing whatever the CachyOS
# ISO happens to ship today.
decman.modules += MODULES
