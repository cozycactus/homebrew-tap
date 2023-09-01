class Soapyrx888 < Formula
  desc "Soapy SDR plugin for the RX-888"
  homepage "https://github.com/cozycactus/SoapyRX888"
  url "https://github.com/cozycactus/SoapyRX888/archive/refs/tags/v1.0.0.tar.gz"
  head "https://github.com/cozycactus/SoapyRX888.git", branch: "main"

    depends_on "cmake" => :build
    depends_on "pkg-config" => :build
    depends_on "soapysdr"
    depends_on "librx888"
    
    def install
        mkdir "build" do
        system "cmake", "..", *std_cmake_args
        system "make"
        system "make", "install"
        end
    end
    
    test do
        system "false"
    end
    end  