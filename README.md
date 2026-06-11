# homebrew-tap

```sh
brew tap cozycactus/tap
brew install avr32-toolchain
```

Homebrew 6 may require tap trust before install:

```sh
brew trust cozycactus/tap
```

`avr32-toolchain` currently supports macOS Apple Silicon. It installs the
preserved AVR32 GCC/binutils/newlib archive and builds `avr32-gdb` from the
Embecosm AVR32 GDB source branch.
