{
  description = "Ty - Type checker for Python";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = "0.0.97";

        x86_64-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-x86_64-unknown-linux-gnu.tar.gz";
          hash = "sha256-0dJX3wUqxdxcahFPf8c6X/QlPg1PcUCVtsh3LP2PG/Q=";
        };

        i686-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-i686-unknown-linux-gnu.tar.gz";
          hash = "sha256-7N1+HbiS9YYkdtauSIU9pAJmM5UDeIJs07ZOEWOjcY4=";
        };

        aarch64-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-aarch64-unknown-linux-gnu.tar.gz";
          hash = "sha256-o2mmrxI6+aG8iIPQOk+Rp83Yj5h1jVkSPjqs1Prlj5M=";
        };

        x86_64-darwin = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-x86_64-apple-darwin.tar.gz";
          hash = "sha256-pfbVWZaRgmqFSKvODDfRcYcHB0A3WB5i2X5A71lJ5B4=";
        };

        aarch64-darwin = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-aarch64-apple-darwin.tar.gz";
          hash = "sha256-jofOipv/gIbR14nOfVl8uxQuSMSOEpY5dGF48JGs/GM=";
        };
      in
      {
        packages.ty = pkgs.stdenv.mkDerivation {
          pname = "ty";
          inherit version;
          src =
            {
              inherit
                x86_64-linux
                i686-linux
                aarch64-linux
                x86_64-darwin
                aarch64-darwin
                ;
            }
            .${system};
          sourceRoot = ".";
          nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.autoPatchelfHook
          ];
          buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.stdenv.cc.cc.lib
          ];
          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp */ty $out/bin/
            chmod +x $out/bin/ty
            runHook postInstall
          '';
          meta = with pkgs.lib; {
            description = "Type checker for Python";
            homepage = "https://github.com/astral-sh/ty";
            license = licenses.mit;
            mainProgram = "ty";
            platforms = [
              "x86_64-linux"
              "i686-linux"
              "aarch64-linux"
              "x86_64-darwin"
              "aarch64-darwin"
            ];
            maintainers = [ ];
          };
        };
        packages.default = self.packages.${system}.ty;
        apps.ty = flake-utils.lib.mkApp {
          drv = self.packages.${system}.ty;
        };
        apps.default = self.apps.${system}.ty;
      }
    );
}
