{
  description = "protonhax";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      version = "1.0.5";
      downloadUrl = {
        "generic" = {
	  url = "https://github.com/jcnils/protonhax/archive/refs/tags/${version}.tar.gz";
   };
      };

      pkgs = import nixpkgs {
        inherit system;
      };

      runtimeLibs = with pkgs; [
        libGL libGLU libevent libffi libjpeg libpng libstartup_notification libvpx libwebp
        stdenv.cc.cc fontconfig libxkbcommon zlib freetype
        gtk3 libxml2 dbus xcb-util-cursor alsa-lib libpulseaudio pango atk cairo gdk-pixbuf glib
	udev libva mesa libnotify cups pciutils
	ffmpeg libglvnd pipewire
      ] ++ (with pkgs.xorg; [
        libxcb libX11 libXcursor libXrandr libXi libXext libXcomposite libXdamage
	libXfixes libXScrnSaver
      ]);

      mkZen = { variant }: 
        let
	  downloadData = downloadUrl."generic";
	in
             pkgs.stdenv.mkDerivation {
    inherit version;
		pname = "protonhax";

		src = builtins.fetchTarball {
		  url = downloadData.url;
		};
		
		desktopSrc = ./.;

		phases = [ "installPhase" "fixupPhase" ];

		nativeBuildInputs = [ pkgs.makeWrapper pkgs.copyDesktopItems pkgs.wrapGAppsHook ] ;

		installPhase = ''
		  mkdir -p $out/bin && cp -r $src/* $out/bin
		'';

		fixupPhase = ''
		  chmod 755 $out/bin/*
		'';

    meta.mainProgram = "protonhax";
	      };
    in
    {
      packages."${system}" = {
        generic = mkZen { variant = "generic"; };
	default = self.packages."${system}".specific;
      };
    };
}
