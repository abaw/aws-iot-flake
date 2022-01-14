{ lib, stdenv, fetchFromGitHub, cmake, openssl }:
let
  json = lib.importJSON ./src.json;
in
stdenv.mkDerivation rec {
  pname = "aws-iot-device-sdk-cpp-v2";
  version = json.rev;
  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl ];
  src = fetchFromGitHub json;
}
