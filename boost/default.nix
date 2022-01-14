# These files are copied from nixpkgs-untable branch of github:NixOS/nixpkgs repository
{ lib
, callPackage
, boost-build
, fetchurl
}:

let
  # for boost 1.55 we need to use 1.56's b2
  # since 1.55's build system is not working
  # with our derivation
  useBoost156 = rec {
    version = "1.56.0";
    src = fetchurl {
      url = "mirror://sourceforge/boost/boost_${lib.replaceStrings ["."] ["_"] version}.tar.bz2";
      sha256 = "07gz62nj767qzwqm3xjh11znpyph8gcii0cqhnx7wvismyn34iqk";
    };
  };

  makeBoost = file:
    lib.fix (self:
      callPackage file {
        boost-build = (boost-build.override {
          # useBoost allows us passing in src and version from
          # the derivation we are building to get a matching b2 version.
          useBoost =
            if lib.versionAtLeast self.version "1.56"
            then self
            else useBoost156; # see above
        }).overrideAttrs(old:
          {
            patches = [];
            # Upstream defaults to gcc on darwin, but we use clang.
            postPatch = ''
              substituteInPlace src/build-system.jam \
              --replace "default-toolset = darwin" "default-toolset = clang-darwin"
            '';
          });
        patches = [ ./boost-math-pch-off.patch ];
      }
    );
in {
  boost177 = makeBoost ./1.77.nix;
}
