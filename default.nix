{ pkgs ? import <nixpkgs> { overlays=[]; config={}; }, ... }:
let
  raw = builtins.readFile ./src/mothershipper.py;
  script = builtins.replaceStrings [''os.path.dirname(os.path.abspath(__file__)) + "/../data"''] ["'${./data}'"] raw;
in
pkgs.writers.writePython3Bin "mothershipper.py" {
  libraries = [];
  doCheck = false;
} script
