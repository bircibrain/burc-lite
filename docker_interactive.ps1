$myname=hostname;
$IP=test-connection "$myname" -count 1;
$myip=$IP.ipv4address.IPAddressToString
set-variable -name DISPLAY -value ${myip}:0.0
docker run -it --rm -e DISPLAY=$DISPLAY $dockerargs rhancock/burc-lite /bin/bash
