{ lib }:
let
  mkConfigurations =
    {
      inputs,
      build,
      defaultModule,
    }:
    hosts:
    lib.mapAttrs (
      hostName:
      {
        system,
        modules ? [ ],
        ...
      }:
      build {
        inherit system;

        specialArgs = { inherit inputs hostName; };

        modules = lib.flatten [
          inputs.nixconf.flakeModules.default

          defaultModule

          (lib.ext.utils.existingPathsRelativeTo inputs.self [
            "hosts/${hostName}/configuration.nix"
            "hosts/${hostName}/hardware-configuration.nix"
          ])

          modules
        ];
      }
    ) hosts;

  errorExample = ''
    For example:

        outputs = inputs@{ nixconf, ... }:
          nixconf.lib.mkHostsFlake { inherit inputs; } { /* module */ };

    Pass the output function arguments as `inputs`. Do not pass
    `self.inputs`, since `inputs` must include `self`.
  '';
in
{
  mkNixosConfigurations =
    inputs:
    mkConfigurations {
      inherit inputs;
      build = inputs.nixpkgs.lib.nixosSystem;
      defaultModule = inputs.nixconf.nixosModules.default;
    };

  mkDarwinConfigurations =
    inputs:
    mkConfigurations {
      inherit inputs;
      build = lib.throwIf (!inputs ? nix-darwin) ''
        mkDarwinConfigurations: forgot to add nix-darwin in inputs?
      '' inputs.nix-darwin.lib.darwinSystem;
      defaultModule = inputs.nixconf.darwinModules.default;
    };

  mkHostsFlake =
    { inputs }:
    module:
    let
      eval = lib.evalModules {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.nixconf.flakeModules.hosts
          module
        ];
      };
    in
    lib.throwIf (!inputs ? self) ''
      mkHostsFlake: `inputs` must include `self`.

      Please pass the output function arguments. ${errorExample}
    '' eval.config.outputs;
}
