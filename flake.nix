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
        version = "0.0.84";

        x86_64-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-x86_64-unknown-linux-gnu.tar.gz";
          hash = "sha256-M2uza36RfYRLixaSXTc7RhSzJuRSyIH/Tta8WQS2UYU=";
        };

        i686-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-i686-unknown-linux-gnu.tar.gz";
          hash = "sha256-CbG8i7QciH1E87xhdB3O5ahaMegxVXG8KaSfnvrVGBc=";
        };

        aarch64-linux = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-aarch64-unknown-linux-gnu.tar.gz";
          hash = "sha256-1XUkPgWGdCrg6RhkQTWL1+V+gWDjGbOvt4FDASZ2Kjk=";
        };

        x86_64-darwin = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-x86_64-apple-darwin.tar.gz";
          hash = "sha256-OJHlUJ0wZyHO5N1OablFNdvZY3GvfsO3NO5l8lsWeuQ=";
        };

        aarch64-darwin = pkgs.fetchurl {
          url = "https://github.com/astral-sh/ty/releases/download/${version}/ty-aarch64-apple-darwin.tar.gz";
          hash = "sha256-xlwJ8nvO9ybAsEPc7o0PHleL0ZNnmeW8RHI1y8PhnZE=";
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
