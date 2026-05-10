import decman

from modules.hardware.zenbook import ZenbookModule
from modules.host.endeavouros import EndeavourOSModule
from roles.laptop import MODULES

# Asus UM5606 (Ryzen AI / Radeon 880M) running EndeavourOS.
# EndeavourOSModule pulls EOS keyring / mirrorlist / branding;
# ZenbookModule layers vendor quirks (asusd, EDID firmware, fnlock,
# fan control) on top of the generic laptop role.
decman.modules += MODULES + [EndeavourOSModule(), ZenbookModule()]
