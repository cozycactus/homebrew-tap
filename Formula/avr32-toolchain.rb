class Avr32Toolchain < Formula
  desc "AVR32 GCC, binutils, newlib, and GDB toolchain"
  homepage "https://github.com/cozycactus/avr32-toolchain-macos-arm64"
  version "3.4.3.20260611"
  license :cannot_represent

  depends_on "bison" => :build
  depends_on "flex" => :build
  depends_on "make" => :build

  on_macos do
    on_arm do
      url "https://github.com/cozycactus/avr32-toolchain-macos-arm64/releases/download/v2026.06.03/avr32-tools-src-macos-arm64-20260603.tar.gz"
      sha256 "7b81496968cc3229d2a65bc699b1c8f9703ee117af9ff12fa7b602211458ad6e"
    end

    on_intel do
      url "https://github.com/cozycactus/avr32-toolchain-macos-arm64/releases/download/v2026.06.03/avr32-tools-src-macos-x86_64-20260611.tar.gz"
      sha256 "bd2f4f583db285c190a6d2525ef9874aa37e2b11a0d04a4aa3f722d931af601e"
    end
  end

  resource "avr32-gdb" do
    url "https://github.com/embecosm/avr32-binutils-gdb/archive/f6fe27a31239536e0c85cfe447debb845b127f6d.tar.gz"
    sha256 "c9b1f10031ef1d3f010a4831ce6b02b2f8b35a6c3f1a6179edd06ac7a1ab0563"
  end

  def install
    odie "avr32-toolchain currently supports macOS only" unless OS.mac?

    toolchain_root =
      if (buildpath/"bin/avr32-gcc").exist?
        buildpath
      elsif (buildpath/"avr32-tools-src/bin/avr32-gcc").exist?
        buildpath/"avr32-tools-src"
      else
        odie "could not find avr32-gcc in the toolchain archive"
      end

    toolchain_prefix = libexec/"avr32-tools-src"
    toolchain_prefix.install Dir[toolchain_root/"*"]
    install_gdb(toolchain_prefix)
    bin.install_symlink Dir[toolchain_prefix/"bin/*"]

    system toolchain_prefix/"bin/avr32-gcc", "--version"
    system toolchain_prefix/"bin/avr32-gdb", "--version"
  end

  def install_gdb(toolchain_prefix)
    make = Formula["make"].opt_bin/"gmake"
    ENV.prepend_path "PATH", Formula["bison"].opt_bin
    ENV.prepend_path "PATH", Formula["flex"].opt_bin
    ENV["MAKEINFO"] = "true"

    resource("avr32-gdb").stage do
      source_root = Pathname.new(Dir.pwd)
      patch_gdb_sources(source_root)

      mkdir "build-gdb" do
        system "../configure",
               "--target=avr32",
               "--prefix=#{toolchain_prefix}",
               "--disable-nls",
               "--disable-werror",
               "--disable-sim",
               "--disable-gdbtk"
        system make, "MAKEINFO=true", "-j#{ENV.make_jobs}", "all-gdb"
        system make, "MAKEINFO=true", "install-gdb"
      end
    end
  end

  def patch_gdb_sources(source_root)
    add_include_after source_root/"readline/rltty.c", "#include <sys/types.h>\n", "#include <sys/ioctl.h>"
    add_include_after source_root/"readline/terminal.c", "#include <sys/types.h>\n", "#include <sys/ioctl.h>"
    add_include_after source_root/"libiberty/regex.c", "#include <ansidecl.h>\n", "#include <stdlib.h>"
    add_include_after source_root/"libiberty/md5.c", "#include <sys/types.h>\n", "#include <string.h>"

    regex = source_root/"libiberty/regex.c"
    allocator_declarations = /
      \n\#\s*if\ defined\ STDC_HEADERS\ \|\|\ defined\ _LIBC
      \n\#\s*include\ <stdlib\.h>
      \n\#\s*else
      \nchar\ \*malloc\ \(\);
      \nchar\ \*realloc\ \(\);
      \n\#\s*endif\n
    /x
    inreplace regex, allocator_declarations, "\n"

    patched_text = regex.read
    return if patched_text.exclude?("char *malloc ();") && patched_text.exclude?("char *realloc ();")

    odie "failed to patch legacy allocator declarations in libiberty/regex.c"
  end

  def add_include_after(path, anchor, include_line)
    text = path.read
    return if text.include?(include_line)

    inreplace path, anchor, "#{anchor}#{include_line}\n"
  end

  def caveats
    <<~EOS
      This formula installs the matching macOS AVR32 compiler archive and
      builds avr32-gdb from Embecosm source.

      Microchip/Atmel device headers are not included. Fetch them separately
      from the upstream toolchain repository if your project needs avr32/io.h.
    EOS
  end

  test do
    assert_match "4.4.7", shell_output("#{bin}/avr32-gcc --version")
    assert_match "6.7.1.atmel.1.0.4", shell_output("#{bin}/avr32-gdb --version")

    (testpath/"smoke.c").write "int main(void){return 0;}\n"
    system bin/"avr32-gcc", "-mpart=uc3a3256", testpath/"smoke.c", "-o", testpath/"smoke.elf"
    assert_match "file format elf32-avr32", shell_output("#{bin}/avr32-objdump -f #{testpath}/smoke.elf")
  end
end
