{ boto3, aws-iot-securetunneling-localproxy, buildPythonApplication }:
let
  localproxy = aws-iot-securetunneling-localproxy;
in
buildPythonApplication {
  name = "start-tunnel";
  propagatedBuildInputs = [ localproxy boto3 ];
  src = ./.;
  dontUseSetuptoolsCheck = true;
  dontUseSetuptoolsBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    sed -e's#<LOCALPROXY_PATH>#"${localproxy}/bin/localproxy"#' start-tunnel > $out/bin/start-tunnel
    chmod +x $out/bin/start-tunnel
  '';
}
