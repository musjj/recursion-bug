{
  self,
  den,
  lib,
  ...
}:
let
  nixpkgsClass =
    ctx:
    lib.optionalAttrs
      (lib.elem (lib.attrNames ctx) [
        [ "home" ]
        [ "host" ]
      ])
      (
        { class, aspect-chain }:
        den._.forward {
          each = [ (ctx.home or ctx.host) ];
          fromClass = _: "nixpkgs";
          intoClass = { class, ... }: class;
          intoPath = _: [ "nixpkgs" ];
          fromAspect = _: lib.head aspect-chain;
          adaptArgs = lib.id;
        }
      );
in
{
  den.hosts.x86_64-linux.igloo.users.tux.classes = [ "homeManager" ];

  den.default = {
    includes = [ nixpkgsClass ];

    nixpkgs.overlays = builtins.attrValues self.outputs.overlays;

    nixos = {
      system.stateVersion = "26.05";
      boot.loader.grub.device = "nodev";
      fileSystems."/" = {
        device = "/dev/sda1";
        fsType = "ext4";
      };
      users.users.tux.isNormalUser = true;
    };

    homeManager.home.stateVersion = "26.05";
  };
}
