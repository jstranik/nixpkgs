{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.spacecookie;
  configFile = pkgs.writeText "spacecookie.json" (lib.generators.toJSON {} {
    inherit (cfg) hostname port root;
  });
in {

  options = {

    services.spacecookie = {

      enable = mkEnableOption "spacecookie";

      package = mkOption {
        type = types.package;
        default = pkgs.haskellPackages.spacecookie;
        example = literalExample ''
          pkgs.haskell.lib.justStaticExecutables pkgs.haskellPackages.spacecookie
        '';
        description = ''
          The spacecookie derivation to use. This can be used to
          override the used package or to use another version.
        '';
      };

      hostname = mkOption {
        type = types.str;
        default = "localhost";
        description = ''
          The hostname the service is reachable via. Clients
          will use this hostname for further requests after
          loading the initial gopher menu.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 70;
        description = ''
          Port the gopher service should be exposed on. The
          firewall is not opened automatically.
        '';
      };

      root = mkOption {
        type = types.path;
        default = "/srv/gopher";
        description = ''
          The root directory spacecookie serves via gopher.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.sockets.spacecookie = {
      description = "Socket for the Spacecookie Gopher Server";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "[::]:${toString cfg.port}" ];
      socketConfig = {
        BindIPv6Only = "both";
      };
    };

    systemd.services.spacecookie = {
      description = "Spacecookie Gopher Server";
      wantedBy = [ "multi-user.target" ];
      requires = [ "spacecookie.socket" ];

      serviceConfig = {
        Type = "notify";
        ExecStart = "${lib.getBin cfg.package}/bin/spacecookie ${configFile}";
        FileDescriptorStoreMax = 1;

        DynamicUser = true;

        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateUsers = true;

        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;

        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        LockPersonality = true;
        RestrictRealtime = true;

        # AF_UNIX for communication with systemd
        # AF_INET replaced by BindIPv6Only=both
        RestrictAddressFamilies = "AF_UNIX AF_INET6";
      };
    };
  };
}
