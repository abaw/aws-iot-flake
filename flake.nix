{
  description = "This flake provides various packages for AWS IoT core. You could use it to set up a quick demo.";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/release-21.11";
  };
  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = self: super: {
        boost177 = (super.callPackage ./boost/. {}).boost177;
        # protobuf3_17 = super.protobuf3_17.overrideAttrs
        #   (old:
        #     {
        #       patches = [ ./protobuf.patch ];
        #       postBuild = super.lib.optionalString super.stdenv.hostPlatform.isStatic ''
        #         sed -i -e "/^dependency_libs=/s#/.*/libstdc++.la#-lstdc++#" src/.libs/libprotobuf{,-lite}.lai
        #       '';
        #     });
        aws-iot-device-sdk-cpp-v2 = super.callPackage ./aws-iot-device-sdk-cpp-v2/. {};
        aws-iot-device-client = self.callPackage ./aws-iot-device-client/. {};
        aws-iot-securetunneling-localproxy =
          let
            boost = self.boost177;
            protobuf = self.protobuf3_17;
            buildProtobuf = self.buildPackages.protobuf3_17;
          in
            super.callPackage
              ./aws-iot-securetunneling-localproxy/. {
                inherit boost protobuf buildProtobuf;
              };
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
          in
            rec {
              packages = {
                sdk-cpp-v2 = pkgs.aws-iot-device-sdk-cpp-v2;
                device-client = pkgs.aws-iot-device-client;
                inherit setup-device-client;
                localproxy = pkgs.aws-iot-securetunneling-localproxy;
                inherit start-tunnel;
              };

              apps = {
                device-client = {
                  type = "app";
                  program = "${packages.device-client}/bin/aws-iot-device-client";
                };
                localproxy = {
                  type = "app";
                  program ="${packages.localproxy}/bin/localproxy";
                };
              };
            }
         );
}