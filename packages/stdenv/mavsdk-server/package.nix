{
  fetchFromGitHub,
  lib,
  git,
  stdenv,
  cmake,
  ninja,
  pkg-config,
  pkgs,
}:

stdenv.mkDerivation rec {
  pname = "mavsdk-server";
  version = "3.6.0";

  outputs = [
    "out"
  ];

  src = fetchFromGitHub {
    owner = "mavlink";
    repo = "MAVSDK";
    rev = "refs/tags/v${version}";
    hash = "sha256-mSpnvqOtUMq8CxDpWmDRH0mt0pKp5QCVb5CESVj/x8U=";
    fetchSubmodules = true;
  };

  #sourceRoot = "src/mavsdk_server";

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        "add_subdirectory(third_party)" \ 
        ""
    '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    #git
  ];

  buildInputs = with pkgs; [
    mavlink
    grpc
    protobuf
    curlFull
    tinyxml-2
    gtest
    jsoncpp
    libevents
  ];

  cmakeFlags = [
    (lib.cmakeBool "SUPERBUILD" false)
    (lib.cmakeFeature "MAVLINK_HEADERS" "${lib.getInclude pkgs.mavlink}")
    (lib.cmakeBool "INSTALL_MAVLINK_HEADERS" false)
    (lib.cmakeBool "BUILD_TESTS" false)
    (lib.cmakeBool "BUILD_TESTING" false)
    (lib.cmakeFeature "MAVSDK_VERSION_STRING" "${version}")
    (lib.cmakeFeature "MAVSDK_SOVERSION_STRING" "${version}")
    (lib.cmakeBool "BUILD_MAVSDK_SERVER" true)
  ];

  doCheck = false;

  meta = with lib; {
    description = "Route mavlink packets between endpoints";
    homepage = "https://github.com/mavlink-router/mavlink-router";
    license = licenses.asl20;
    teams = [ teams.gnome ];
  };
}
