{ stdenv, aws-iot-device-client }:
stdenv.mkDerivation rec {
  pname = "setup-device-client";
  version = aws-iot-device-client.version;
  src = aws-iot-device-client.src;
  patches = [ ./setup.patch ];
  installPhase = ''
    mkdir -p $out
    sed -e "s|^\s*DEVICE_CLIENT_ARTIFACT_DEFAULT=.*\$|DEVICE_CLIENT_ARTIFACT_DEFAULT=${aws-iot-device-client}/bin/aws-iot-device-client|" \
    -e "s|^\s*SERVICE_FILE_DEFAULT=.*\$|SERVICE_FILE_DEFAULT=$src/setup/aws-iot-device-client.service|" \
    setup.sh > "$out/setup.sh"
    chmod +x "$out/setup.sh"
  '';
}
