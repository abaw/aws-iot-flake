{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, aws-iot-device-sdk-cpp-v2 }:
let
  json = lib.importJSON ./src.json;
in
stdenv.mkDerivation rec {
  pname = "aws-iot-device-client";
  version = json.rev;
  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ aws-iot-device-sdk-cpp-v2 ];
  src = fetchFromGitHub json;
  patches = [ ./cmakelists.patch ./missing_includes.patch ];
  cmakeFlags = [ "-DBUILD_SDK=OFF -DBUILD_TEST_DEPS=OFF" ];
  installPhase = ''
    mkdir -p "$out/bin"
    cp aws-iot-device-client "$out/bin"
  '';
}

