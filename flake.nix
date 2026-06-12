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
        version = "0.0.49";

        x86_64-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-x86_64-unknown-linux-gnu.tar.gz";
          hash = "sha256-791UovX9xWFBR7DV705jFCvFppjE6uL/Tz/YgVdycE4=";
        };

        i686-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-i686-unknown-linux-gnu.tar.gz";
          hash = "sha256-vny8rc+FkXG2o36DPf73eacT7XMU3dox8wWrXnnPnU4=";
        };

        aarch64-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-aarch64-unknown-linux-gnu.tar.gz";
          hash = "sha256-dJTuDz56za0oa8zk6tP46lt/cyKS6HO9P/ADu9lb6PE=";
        };

        x86_64-darwin = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-x86_64-apple-darwin.tar.gz";
          hash = "sha256-cblt1lF2M68OffkHpBEWz+QmaD+qAOdTAG/Z7GNU/BA=";
        };

        aarch64-darwin = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-aarch64-apple-darwin.tar.gz";
          hash = "sha256-N/d6XJd9FYvSiZewhm5fPYkqe77YgYgXEcDKBBHdEqo=";
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
