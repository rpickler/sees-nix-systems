{
  fetchFromGitHub,
  lib,
  stdenv,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  pkgs,
}:

stdenv.mkDerivation rec {
  pname = "mavlink-router";
  version = "4";

  outputs = [
    "out"
  ];

  src = fetchFromGitHub {
    owner = "mavlink-router";
    repo = "mavlink-router";
    rev = "refs/tags/v${version}";
    hash = "sha256-Uk4bJe0UJbg1eg1iTLJjbTbI6aeCT9PVo4weS1irQDw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    systemd
  ];

  mesonFlags = [
    "-Dsystemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Route mavlink packets between endpoints";
    homepage = "https://github.com/mavlink-router/mavlink-router";
    license = licenses.asl20;
    teams = [ teams.gnome ];
  };
}
