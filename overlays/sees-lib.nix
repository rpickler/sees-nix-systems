final: prev: {
  sees-lib = builtins.listToAttrs (
    builtins.map
      (name: { 
        name = (prev.lib.strings.removeSuffix ".nix" name); 
        value = import ../lib/${name} { pkgs = prev; };
      })
      (builtins.attrNames (builtins.readDir ../lib))
  );
}

