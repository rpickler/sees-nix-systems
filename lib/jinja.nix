{ pkgs }: 
  outfile: template: args:
  let
    vars = builtins.concatStringsSep " " (pkgs.lib.attrsets.mapAttrsToList
      (key: val: "-D ${key}=${val}")
      args
    );
  in
    pkgs.runCommandWith
      {
        name = outfile;
        derivationArgs.nativeBuildInputs = [ pkgs.jinja2-cli ];
      }
      ''
      mkdir -p $out
      echo "${template}" > ${outfile}.j2
      jinja2 ${vars} ${outfile}.j2 -o $out/${outfile}
      rm ${outfile}.j2
      ''
