{
  inputs,
  lib,
}:
{
  default = final: prev: {
    nixconf = prev.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ../pkgs;
    };
  };
}
