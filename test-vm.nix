{ lib, config, ... }:
let
  shipperPort = lib.toInt (
    builtins.replaceStrings [":"] [""]
    config.services.uwsgi.instance.vassals.mothershipper.http
  );
in
{
  users.users.root.hashedPassword = "";
  services.getty.autologinUser = "root";

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = config.system.nixos.release;

  virtualisation.vmVariant = {
    virtualisation = {
      diskImage = null;
      mountHostNixStore = true;
      writableStoreUseTmpfs = false;
      forwardPorts = [{ from = "host"; host.port = shipperPort; guest.port = shipperPort; }];
    };
    networking.firewall.allowedTCPPorts = [ shipperPort ];
  };
  environment.shellAliases = {
    sht = "sudo shutdown -h now";
    jj = "sudo journalctl -e -u ";
    jm = "sudo netstat -tulpen; sudo journalctl -e -u uwsgi.service";
    cm = "curl http://127.0.0.1:${toString shipperPort}?num_chars=10";
  };
}
