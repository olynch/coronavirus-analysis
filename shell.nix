{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
   pkgs.buildFHSUserEnv {
  name = "julia-fhs";
  targetPkgs = pkgs: with pkgs;
    [
      autoconf
      curl
      gnumake
      utillinux
      m4
      gperf
      unzip
      stdenv.cc
      clang
      binutils
      which
      gmp
      libxml2
      cmake

      fontconfig
      openssl
      which
      ncurses
      gtk2-x11
      atk
      gdk_pixbuf
      cairo
      xorg.libX11
      xorg.xorgproto
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXext
      xorg.libSM
      xorg.libICE
      xorg.libX11
      xorg.libXrandr
      xorg.libXdamage
      xorg.libXrender
      xorg.libXfixes
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libxcb
      xorg.libXi
      xorg.libXScrnSaver
      xorg.libXtst
      xorg.libXt
      xorg.libXxf86vm
      xorg.libXinerama
      nspr
      pdf2svg

      # Nvidia note: may need to change cudnn to match cudatoolkit version
      # cudatoolkit_10_0
      # cudnn_cudatoolkit_10_0
      # linuxPackages.nvidia_x11

      julia_13

      # Arpack.jl
      arpack
      gfortran.cc
      (pkgs.runCommand "openblas64_" {} ''
        mkdir -p "$out"/lib/
        ln -s ${openblasCompat}/lib/libopenblas.so "$out"/lib/libopenblas64_.so.0
      '')

      # Cairo.jl
      cairo
      gettext
      pango.out
      glib.out
      # Gtk.jl
      gtk3
      gtk2
      fontconfig
      gdk_pixbuf
      # GR.jl # Runs even without Xrender and Xext, but cannot save files, so those are required
      qt4
      glfw
      freetype

      conda

      #misc
      xorg.libXxf86vm
      xorg.libSM
      xorg.libXtst
      libpng
      expat
      gnome2.GConf
      nss
    ];
  multiPkgs = pkgs: with pkgs; [ zlib ];
  runScript = "bash";
  extraOutputsToInstall = ["man" "dev"];
  profile = ''
    export EXTRA_CCFLAGS="-I/usr/include"
  '';
}

  ];
}
