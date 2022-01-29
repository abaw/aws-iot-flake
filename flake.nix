{
  description = "This flake provides various packages for AWS IoT core. You could use it to set up a quick demo.";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/release-21.11";
  };
  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = final: prev: {
        boost177 = (prev.callPackage ./boost/. {}).boost177;
        # protobuf3_17 = prev.protobuf3_17.overrideAttrs
        #   (old:
        #     {
        #       patches = [ ./protobuf.patch ];
        #       postBuild = prev.lib.optionalString prev.stdenv.hostPlatform.isStatic ''
        #         sed -i -e "/^dependency_libs=/s#/.*/libstdc++.la#-lstdc++#" src/.libs/libprotobuf{,-lite}.lai
        #       '';
        #     });
        aws-iot-securetunneling-localproxy =
          let
            boost = final.boost177;
            protobuf = final.protobuf3_17;
            buildProtobuf = final.buildPackages.protobuf3_17;
          in
            prev.callPackage
              ./aws-iot-securetunneling-localproxy/. {
                inherit boost protobuf buildProtobuf;
              };
      } // prev.lib.optionalAttrs (prev.stdenv.isLinux) {
        aws-iot-device-sdk-cpp-v2 = prev.callPackage
          ./aws-iot-device-sdk-cpp-v2/.
          (prev.lib.optionalAttrs prev.stdenv.isAarch64
            { stdenv = prev.clangStdenv; }
          );
        aws-iot-device-client = final.callPackage ./aws-iot-device-client/. {};
      };
    in
      {
        inherit overlay;
      } // flake-utils.lib.eachDefaultSystem
        (system:
          let
            pkgs = import nixpkgs { inherit system; overlays = [overlay]; };
            # pkgs-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.pkgsStatic;
            python = pkgs.python3;
            setup-device-client = pkgs.callPackage ./setup-device-client/. {};
            start-tunnel = python.pkgs.callPackage ./start-tunnel/. {};
            ipython-boto3 = python.withPackages (ps: with ps; [ipython boto3]);
            mkCheck = pkg: command:
              pkgs.runCommandNoCC pkg.name {
                buildInputs = [pkg];
              } ''
              ${command}
              touch $out
              '';
          in
            with pkgs;
            rec {
              packages = {
                localproxy = aws-iot-securetunneling-localproxy;
                inherit start-tunnel;
              } // lib.optionalAttrs (pkgs ? aws-iot-device-sdk-cpp-v2) {
                sdk-cpp-v2 = aws-iot-device-sdk-cpp-v2;
                device-client = aws-iot-device-client;
                inherit setup-device-client;
              };

              checks = lib.overrideExisting packages {
                localproxy = mkCheck packages.localproxy "localproxy --help";
                start-tunnel = mkCheck packages.start-tunnel "start-tunnel --help";
                device-client = mkCheck packages.device-client "aws-iot-device-client --help";
                sdk-cpp-v2 =
                    runCommandCC "sdk-cpp-v2" {
                      buildInputs = devShells.dev-sdk-cpp-v2.buildInputs;
                    } ''
                    cmake ${packages.sdk-cpp-v2.src}/samples/greengrass/ipc
                    cmake --build .
                    ./greengrass-ipc --help
                    touch $out
                    '';
              };

              apps = {
                localproxy = {
                  type = "app";
                  program ="${packages.localproxy}/bin/localproxy";
                };
              } // lib.optionalAttrs (packages ? device-client) {
                device-client = {
                  type = "app";
                  program = "${packages.device-client}/bin/aws-iot-device-client";
                };
              };

              devShells = lib.optionalAttrs (packages ? sdk-cpp-v2) {
                dev-sdk-cpp-v2 = mkShell {
                  buildInputs = [ cmake packages.sdk-cpp-v2 ];
                };
              };
            }
         );
}
