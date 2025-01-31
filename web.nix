{ lib, uwsgi, writeScriptBin, mothershipper }:
let
  uwsgpy = uwsgi.override { plugins = [ "python3" ]; };
in
writeScriptBin "motherwebber" ''
  #!/bin/sh
  port=":''${1?Need port as first argument}"
  shift
  exec ${lib.getExe uwsgpy} --plugin python3 --http "$port" --wsgi-file "${mothershipper}/bin/mothershipper.py" "$@"
''
