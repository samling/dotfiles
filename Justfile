root := justfile_directory()
host := `hostname`

init:
    chezmoi init --source={{root}}
    sudo decman --source={{root}}/decman/source.py

apply:
    sudo decman

dry-run:
    sudo decman --dry-run

update:
    sudo DECMAN_NO_UPGRADE=1 decman
