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
        version = "0.0.60";

        x86_64-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-x86_64-unknown-linux-gnu.tar.gz";
          hash = "sha256-zVx8bWCi61INc1cUi0Yjgc0ViSYSh3PBZGAWvNm9s+I=";
        };

        i686-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-i686-unknown-linux-gnu.tar.gz";
          hash = "sha256-bSSxT9pIjfxA9W1fusxCob5N79xIKT5xLI6zuHvfUOs=";
        };

        aarch64-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-aarch64-unknown-linux-gnu.tar.gz";
          hash = "sha256-QZettxS48Ll3J14PI0aAfUQLpFjNdsMA7Xa+EQkgkEo=";
        };

        x86_64-darwin = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-x86_64-apple-darwin.tar.gz";
          hash = "sha256-DSZAl7Uo6BOxUXJkfSt+5J2KniwBWerJCbOVDRgrJNc=";
        };

        aarch64-darwin = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-aarch64-apple-darwin.tar.gz";
          hash = "sha256-RO1xNB+jtE/ggZQdbDp3NXSUdt27zboIz+k3PN1qe/g=";
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
          nativeBuildInputs = [ pkgs.autoPatchelfHook ];
          buildInputs = with pkgs; [
            stdenv.cc.cc.lib
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
