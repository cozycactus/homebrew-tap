# librx888.rb
class Librx888 < Formula
    desc "Library for RX888 SDR"
    homepage "https://github.com/cozycactus/librx888"
    url "https://github.com/cozycactus/librx888/archive/refs/tags/v1.0.0.tar.gz"
    sha256 "a00046443470384cd65b09f681a0636f286276048bf939d8dd94bda049dd4467"
    license "GPL-2.0"
    head "https://github.com/cozycactus/librx888.git", branch: "main"
  
    depends_on "cmake" => :build
    depends_on "pkg-config" => :build
    depends_on "libusb"
  
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