{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "toofan";
  version = "v1.1.2";  # or a tag if there is one

  src = fetchFromGitHub {
    owner = "vyrx-dev";
    repo = "toofan";
    rev = "master";  # pin to a commit sha for reproducibility
    hash = "sha256-e1lzoNc++L0P5BQIoTzZXGlvazj/7/aCNcJFDvYe65Q=";
  };

  vendorHash = "sha256-YSjJ8NOL97hXZLnfGYIjoKmARv+gWOsv+5qkl9konnA=";

  meta = {
    description = "Minimal, lightning-fast typing TUI";
    homepage = "https://github.com/vyrx-dev/toofan";
    mainProgram = "toofan";
  };
}

