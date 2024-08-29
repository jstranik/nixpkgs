{ lib, stdenv, fetchFromGitHub, fetchpatch, autoconf, automake, libtool, python3, boost, enablePythonBindings ? true }:

stdenv.mkDerivation rec {
  pname = "quickfix";
  version = "1.15.1";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev =  "v${version}";
    sha256 = "1fgpwgvyw992mbiawgza34427aakn5zrik3sjld0i924a9d17qwg";
  };

  patches = [
    # Improved C++17 compatibility
    (fetchpatch {
      url = "https://github.com/quickfix/quickfix/commit/a46708090444826c5f46a5dbf2ba4b069b413c58.diff";
      sha256 = "1wlk4j0wmck0zm6a70g3nrnq8fz0id7wnyxn81f7w048061ldhyd";
    })
    ./disableUnitTests.patch
    ./glibtoolize.patch
    ./python.patch
  ];

  configureFlags = lib.optional enablePythonBindings ["--with-python3"];
  # autoreconfHook does not work
  nativeBuildInputs = [ autoconf automake libtool
                        (python3.withPackages (ps: with ps; [ setuptools ]))
                      ];
  buildInputs = [ boost ];

  CPPFLAGS="-DENABLE_BOOST_ATOMIC_COUNT";

  enableParallelBuilding = true;

  preConfigure = ''
    ./bootstrap
  '';

  # More hacking out of the unittests
  preBuild = ''
    substituteInPlace Makefile --replace 'UnitTest++' ' '
  '';

  meta = with lib; {
    description = "QuickFIX C++ Fix Engine Library";
    homepage = "http://www.quickfixengine.org";
    license = licenses.free; # similar to BSD 4-clause
    maintainers = with maintainers; [ bhipple ];
  };
}
