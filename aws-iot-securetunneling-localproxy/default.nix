{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, buildProtobuf, protobuf, boost, zlib, openssl, catch2 }:
let
  json = lib.importJSON ./src.json;
in
stdenv.mkDerivation rec {
  pname = "aws-iot-securetunneling-localproxy";
  version = json.rev;
  nativeBuildInputs = [ cmake pkg-config buildProtobuf ];
  buildInputs = [ boost protobuf zlib openssl catch2 ];
  src = fetchFromGitHub json;
  # cmakeFlags = [ "-DProtobuf_PROTOC_EXECUTABLE=${protobuf4build}/bin/protoc" ];
  NIX_CFLAGS_COMPILE = [ "-I${catch2}/include" ];
  installPhase = ''
    mkdir -p "$out/bin"
    cp bin/localproxy "$out/bin"
  '';
}

