let
  morpheusIp = "100.116.158.45";
in {
  allowedTCPPorts = [
    80
    443
  ];
  extraCommands = ''
    iptables -t nat -A PREROUTING -p tcp -i enp1s0 --dport 32400 -j DNAT --to-destination ${morpheusIp}:32400
    iptables -I FORWARD -p tcp -d ${morpheusIp} --dport 32400 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
    iptables -I POSTROUTING -t nat -p tcp -d ${morpheusIp} --dport 32400 -j MASQUERADE

    iptables -t nat -A PREROUTING -p tcp -i enp1s0 --dport 25565 -j DNAT --to-destination ${morpheusIp}:25565
    iptables -I FORWARD -p tcp -d ${morpheusIp} --dport 25565 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
    iptables -I POSTROUTING -t nat -p tcp -d ${morpheusIp} --dport 25565 -j MASQUERADE
  '';
  extraStopCommands = ''
    iptables -t nat -D PREROUTING -p tcp --dport 32400 -j DNAT --to-destination ${morpheusIp}:32400 || true
    iptables -D FORWARD -p tcp -d ${morpheusIp} --dport 32400 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
    iptables -D POSTROUTING -t nat -p tcp -d ${morpheusIp} --dport 32400 -j MASQUERADE

    iptables -t nat -D PREROUTING -p tcp --dport 25565 -j DNAT --to-destination ${morpheusIp}:25565 || true
    iptables -D FORWARD -p tcp -d ${morpheusIp} --dport 25565 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
    iptables -D POSTROUTING -t nat -p tcp -d ${morpheusIp} --dport 25565 -j MASQUERADE
  '';
}
