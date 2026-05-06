import decman

from modules.zenbook import ZenbookModule
from roles.laptop import MODULES

# Asus UM5606 (Ryzen AI / Radeon 880M). ZenbookModule layers vendor
# quirks (asusd, EDID firmware, fnlock, fan control) on top of the
# generic laptop role.
decman.modules += MODULES + [ZenbookModule()]
