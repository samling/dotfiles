{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "command-snippets";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "samling";
    repo = "command-snippets";
    rev = "v${version}";
    hash = "sha256-7IadnnoIvEPbrtP4UFf16dIGPUT00MdWwp9/n8sOkkA=";
  };

  vendorHash = "sha256-o1zT1XczVYtFW51lT3u+E0kCRdwQ8BibPGh4Rdo5BIk=";

  subPackages = [ "cmd/cs" ];

  meta = {
    description = "Fuzzy-searchable command snippet manager";
    homepage = "https://github.com/samling/command-snippets";
    mainProgram = "cs";
  };
}
