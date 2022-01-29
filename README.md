# aws-iot-flake
Nix flakes for AWS IoT Core packages

## Supported platforms
- MacOS x86-64
- Linux x86-64/aarch64

## Prerequisites
- Install Nix by following the instructions:
  <https://nixos.org/manual/nix/stable/installation/installing-binary.html>
  
- Enable nix flake feature by adding a file `~/.config/nix/nix.conf` with the
  following contents:
  
        experimental-features = nix-command flakes

## Development with aws-iot-device-sdk-cpp-v2
You will dropped in a shell where everything for developing with
aws-iot-device-sdk-cpp-v2 is available:

    >nix develop github:abaw/aws-iot-flake#dev-sdk-cpp-v2
    # In this shell, cmake and the SDK are installed so that `find_package(aws-crt-cpp)` works in CMakeLists.txt.
    # You could try with the sample app: https://github.com/aws/aws-iot-device-sdk-cpp-v2/tree/main/samples/mqtt/basic_pub_sub
    >cd <path-to-sample>
    >mkdir build
    >cmake ..
    >cmake --build .
    
## AWS IoT Secure Tunnelling
You could learn what's AWS IoT Secure Tunnelling at: <https://docs.aws.amazon.com/iot/latest/developerguide/secure-tunneling.html>.

Follow the instructions to quickily set up a working tunnel:

1. Follow this document to create a thing:
   <https://docs.aws.amazon.com/iot/latest/developerguide/create-iot-resources.html>   
   You should copy the certificates and keys to your device.
2. Make sure you have correctly configured your aws cli:
   <https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html>
3. Make sure Nix is both installed on your host and on the device you want to create a tunnel to.
4. On the device(the destination of a secure tunnel), run the following command
   to install aws-iot-device-client service:
   
        >nix build github:abaw/aws-iot-flake#setup-device-client
        >sudo ./result/setup.sh
       
   You will be asked for a lot of questions, you could answer them as the following:
           
        WARNING: Only run this setup script as root if you plan to run the AWS IoT Device Client as root,  or if you plan to run the AWS IoT Device Client as a service. Otherwise, you should run this script as  the user that will execute the client.
        Do you want to interactively generate a configuration file for the AWS IoT Device Client? y/n
        y
        Specify AWS IoT endpoint to use:
        <your-endpoint>
        Specify path to public PEM certificate:
        <path-to-device-certificate>
        Specify path to private key:
        <path-to-device-private-key>
        Specify path to ROOT CA certificate:
        <path-to-amazon-root-ca>
        Specify thing name (Also used as Client ID):
        <thing-name>
        Would you like to configure the logger? y/n
        n
        Enable Jobs feature? y/n
        n
        Enable Secure Tunneling feature? y/n
        y
        Enable Device Defender feature? y/n
        n
        Enable Fleet Provisioning feature? y/n
        n
        Enable Pub Sub sample feature? y/n
        n
        Enable Config Shadow feature? y/n
        n
        Enable Sample Shadow feature? y/n
        n
        Does the following configuration appear correct? If yes, configuration will be written to /root/.aws-iot-device-client/aws-iot-device-client.conf: y/n
        
            {
              "endpoint":       "<your-endpoint>",
              "cert":   "<path-to-device-certificate>",
              "key":    "<path-to-device-private-key>",
              "root-ca":        "<path-to-amazon-root-ca>",
              "thing-name":     "<thing-name>",
              "logging":        {
                "level":        "DEBUG",
                "type": "STDOUT",
                "file": "/var/log/aws-iot-device-client/aws-iot-device-client.log",
                "enable-sdk-logging":   false,
                "sdk-log-level":        "TRACE",
                "sdk-log-file": "/var/log/aws-iot-device-client/sdk.log"
              },
              "jobs":   {
                "enabled":      false,
                "handler-directory": "/root/.aws-iot-device-client/jobs"
              },
              "tunneling":      {
                "enabled":      true
              },
              "device-defender":        {
                "enabled":      false,
                "interval": 300
              },
              "fleet-provisioning":     {
                "enabled":      false,
                "template-name": "",
                "template-parameters": "",
                "csr-file": "",
                "device-key": ""
              },
              "samples": {
                "pub-sub": {
                  "enabled": false,
                  "publish-topic": "",
                  "publish-file": "/root/.aws-iot-device-client/pubsub/publish-file.txt",
                  "subscribe-topic": "",
                  "subscribe-file": "/root/.aws-iot-device-client/pubsub/subscribe-file.txt"
                }
              },
              "config-shadow":  {
                "enabled":      false
              },
              "sample-shadow": {
                "enabled": false,
                "shadow-name": "",
                "shadow-input-file": "",
                "shadow-output-file": ""
              }
            }
        y
        Configuration has been successfully written to /root/.aws-iot-device-client/aws-iot-device-client.conf
        Creating default pubsub directory...
        Do you want to copy the sample job handlers to the specified handler directory (/root/.aws-iot-device-client/jobs)? y/n
        n
        Do you want to install AWS IoT Device Client as a service? y/n
        y
        Do you want to run the AWS IoT Device Client service via Valgrind for debugging? y/n
        n
        Installing AWS IoT Device Client...

5. On the source host, you could open a tunnel by the following command:
        
        >nix run github:abaw/aws-iot-flake#start-tunnel -- <region> <thing-name> <local-port>
        
   As long as the process is running, you could ssh to your device through the
   local port `<local-port>`. Your ssh connection will be forwarded to the
   device. Here is a sample session:
   
        >nix run github:abaw/aws-iot-flake#start-tunnel -- us-east-1 my-thing 5555
        # at another terminal
        >ssh -p5555 <user>@localhost

