{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "cpprest";

  src = fetchFromGitHub {
    owner = "Microsoft";
    repo = "cpprestsdk";
    rev = "65267c6e83e7e29ed3bdddde13d2c4bbb10e1bff";
    sha256 = "1czp3w53c175lmrffh7357j2l1w2jbviqzjkppc2nydcpf4kylvc";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    boost166
    openssl
    zlib
  ];

  # doCheck = true;
  # checkTarget = "test";

  meta = with stdenv.lib; {
    description = "The C++ REST SDK is a Microsoft project for cloud-based client-server communication in native code using a modern asynchronous C++ API design. This project aims to help C++ developers connect to and interact with services.";
    homepage = https://github.com/Microsoft/cpprestsdk;
    license = licenses.mit;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
