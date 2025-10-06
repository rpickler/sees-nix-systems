{
  fetchFromGitHub,
  lib,
  stdenv,
  cmake,
  ninja,
  pkg-config,
  pkgs,
}:

stdenv.mkDerivation rec {
  pname = "libevents";
  version = "0.0.1";

  outputs = [
    "out"
  ];

  src = fetchFromGitHub {
    owner = "mavlink";
    repo = "libevents";
    rev = "7c1720749dfe555ec2e71d5f9f753e6ac1244e1c";
    hash = "sha256-qzY2FOgc+iD5bYXJGj6ftWUA3cEC14Dwz0ZFr7WCtro=";
  };

  sourceRoot = "source/libs/cpp";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  #buildInputs = with pkgs; [
  #];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_TESTING" false)
  ];

  doCheck = false;

  meta = with lib; {
    description = "Route mavlink packets between endpoints";
    homepage = "https://github.com/mavlink-router/mavlink-router";
    license = licenses.asl20;
    teams = [ teams.gnome ];
  };
}
