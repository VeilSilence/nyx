{
  nixpkgs,
  inputs,
  ...
}: let
  inherit (nixpkgs) lib;
  inherit (lib) foldl recursiveUpdate;

  # a modified version of NUR's dag type
  dag = import ./dag.nix {inherit lib;};

  # helpful utility functions used around the system
  builders = import ./builders.nix {inherit inputs lib;};
  services = import ./services.nix {inherit lib;};
  validators = import ./validators.nix {inherit lib;};
  helpers = import ./helpers.nix {inherit lib;};
  hardware = import ./hardware.nix {inherit lib;};
  aliases = import ./aliases.nix {inherit lib;};
  firewall = import ./firewall.nix {inherit lib dag;};

  # recursively merges two attribute sets
  mergeRecursively = lhs: rhs: recursiveUpdate lhs rhs;
in
  # extend nixpkgs lib
  lib.extend (_: _: foldl mergeRecursively {} [builders services validators helpers hardware aliases firewall dag])
