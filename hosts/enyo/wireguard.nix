{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.firewall = {
    allowedUDPPorts = [51820]; # Clients and peers can use the same port, see listenpor
  };
  # Wireguard Client Peer Setup
  networking.wireguard = {
    enable = true;
    

    interfaces = {
      wg1 = {
      privateKeyFile = config.age.secrets.wg-client.path;
        allowedIPsAsRoutes = true;
        ips = [
          "10.255.255.11/32"
          "2a01:4f9:c010:2cf9:f::11/128"
        ];
        peers = [
          {
            allowedIPs = [
              "10.255.255.0/24"
              "2a01:4f9:c010:2cf9:f::/80"
            ];
            endpoint = "notashelf.dev:51820";
            publicKey = "v3ol3QsgLPudVEtbETByQ0ABAOrJE2WcFfQ/PQAD8FM=";
            persistentKeepalive = 30;
          }
        ];
      };
    };
  };
}
