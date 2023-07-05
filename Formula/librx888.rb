# librx888.rb
class Librx888 < Formula
    desc "Library for RX888 SDR"
    homepage "https://github.com/cozycactus/librx888"
    head "https://github.com/cozycactus/librx888.git", , branch: "main"
  
    depends_on "cmake" => :build
    depends_on "libusb"
  
    def install
      system "mkdir", "build"
      system "cd", "build"
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  
    test do
      system "false"
    end
  end