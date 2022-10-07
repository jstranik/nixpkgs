{ lib, stdenv
, cmake
, fetchFromGitHub
, openssl
, c-ares
, tl-expected
}:

stdenv.mkDerivation rec {
  pname = "libfrozen";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "serge-sans-paille";
    repo = "frozen";
    rev = "1.1.1";
    sha256 = "sha256-HebDTRg1+snUwu+KumrgNMt/GOWXdHM9pMgXi51eArk=";
    # url = "https://github.com/jbaldwin/libcoro.git";
    # rev = "main";
  };

  #outputs = [ "out" "dev" ];

  nativeBuildInputs = [ cmake  ];

  propagatedBuildInputs = [ ];
  #buildInputs = [ openssl.dev ];
  #patches = [ ./cmake_install.patch ];
  #patchFlags = [ "-p2" ];

  meta = with lib; {
    homepage = "https://github.com/serge-sans-paille/frozen";
    description = "A consteval containers library for C++";
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = with maintainers; [ jstranik ];
  };
}
