import decman


class ChezmoiModule(decman.Module):

    def __init__(self):
        super().__init__("chezmoi")

    def before_update(self, store):
        print("Applying latest chezmoi config")
        decman.prg(
            ["chezmoi", "apply"],
            user="sboynton",
            mimic_login=True,
            check=True,
        )
