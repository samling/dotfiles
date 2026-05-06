host := `hostname`

apply:
    sudo decman

dry-run:
    sudo decman --dry-run

update:
    sudo DECMAN_NO_UPGRADE=1 decman
