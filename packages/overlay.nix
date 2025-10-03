(final: prev: 
  builtins.mapAttrs
    (name: _: prev.callPackage ./stdenv/${name}/package.nix { })
    (builtins.readDir ./stdenv)
)
