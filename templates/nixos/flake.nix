{
  description = "__DESCRIPTION__";

  outputs = {nixconf, ...} @ inputs:
    nixconf.lib.mkHostsFlake inputs {
      hosts = {
        __HOSTNAME__ = {
          system = "__SYSTEM__";
          modules = [];
        };
      };

      checks = pkgs: {};
      devShells = pkgs: {};
    };

  inputs = {
    nixconf.url = "github:d3vnrd/nixconf";

    nixpkgs.follows = "nixconf/nixpkgs";
    home-manager.follows = "nixconf/home-manager";
  };
}
