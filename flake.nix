{
  description = "Flake providing the R language server with a wrapped R";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, ... }:
        let
          myR = pkgs.rWrapper.override {
            packages = with pkgs.rPackages; [ languageserver ];
          };

          rLanguageServer = pkgs.writeShellScriptBin "r_language_server" ''
            exec ${myR}/bin/R --slave -e "languageserver::run()" "$@"
          '';

        in
        {
          packages.r-language-server = rLanguageServer;
          packages.default = rLanguageServer;
          devShells.default = pkgs.mkShell {
            packages = [ rLanguageServer ];
          };
        };
    };
}
