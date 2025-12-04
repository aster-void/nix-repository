{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  fcitx5,
  vulkan-loader,
  llama,
  zenzai,
  passthru,
  qt6,
  ...
}: let
  version = "0.2.0";
in
  stdenv.mkDerivation {
    pname = lib.warn "fcitx5-hazkey is deprecated. Please migrate to nix-hazkey: https://github.com/aster-void/nix-hazkey" "fcitx5-hazkey";
    inherit version;

    src = fetchzip {
      url = "https://github.com/7ka-Hiira/fcitx5-hazkey/releases/download/${version}/fcitx5-hazkey-${version}-x86_64.tar.gz";
      hash = "sha256-agpqU8uVpmGJEnqQPsZBv3uSOw9pD0iri3/R/hRAACA=";
      stripRoot = false;
    };

    buildInputs = [
      fcitx5
      vulkan-loader
      stdenv.cc.cc.lib
      qt6.qtbase
      qt6.qtwayland
    ];
    nativeBuildInputs = [
      autoPatchelfHook
      qt6.wrapQtAppsHook
    ];

    patchPhase = ''
      runHook prePatch

      # Move everything from usr/ to current directory
      mv usr/* .
      rmdir usr

      # fcitx5 does not search under /lib/x86_64-linux-gnu/
      # therefore it must be flattened to /lib/
      mv lib/x86_64-linux-gnu/* lib/
      rmdir lib/x86_64-linux-gnu

      runHook postPatch
    '';

    installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp -r . $out/

            # Install llama libraries
            cp -r ${llama}/lib/hazkey/llama $out/lib/hazkey/

            # Install zenzai model
            mkdir -p $out/share/hazkey
            cp ${zenzai}/share/hazkey/zenzai.gguf $out/share/hazkey/

            # Remove llama-stub since we have the real llama libraries now
            rm -r $out/lib/hazkey/llama-stub

            # Fix broken symlink in bin/hazkey-settings
            # Upstream tarball has absolute path symlink that doesn't work in nix
            rm $out/bin/hazkey-settings
            ln -s ../lib/hazkey/hazkey-settings $out/bin/hazkey-settings

            # Rewrite hazkey-server wrapper for NixOS
            # Original script has hardcoded /usr paths that don't work
            cat > $out/bin/hazkey-server <<EOF
      #!/bin/sh
      # hazkey-server wrapper script for NixOS
      # Uses bundled zenzai by default, or user can override with LIBLLAMA_PATH

      if [ -z "\$XDG_CONFIG_HOME" ]; then
          XDG_CONFIG_HOME="\$HOME/.config"
      fi

      # Load user defined environment variables
      ENV_FILE="\$XDG_CONFIG_HOME/hazkey/environment"
      if [ -f "\$ENV_FILE" ]; then
          . "\$ENV_FILE"
      fi

      # Default to bundled zenzai, allow user override via LIBLLAMA_PATH
      if [ -z "\$LIBLLAMA_PATH" ]; then
          LIBLLAMA_PATH="$out/lib/hazkey/llama/libllama.so"
      fi

      # Load libllama if available
      if [ -f "\$LIBLLAMA_PATH" ]; then
          export LD_PRELOAD="\$LIBLLAMA_PATH"
      else
          echo "Warning: libllama.so not found at \$LIBLLAMA_PATH" >&2
          echo "Starting hazkey-server without LD_PRELOAD (using stub library)" >&2
      fi

      exec "$out/lib/hazkey/hazkey-server" "\$@"
      EOF
            chmod +x $out/bin/hazkey-server

            runHook postInstall
    '';

    inherit passthru;
    meta = with lib; {
      homepage = "https://hazkey.hiira.dev/";
      description = "Japanese input method for fcitx5, powered by azooKey engine";
      license = licenses.mit;
      maintainers = [];
      platforms = ["x86_64-linux"];
      # no main program because this is not executable
    };
  }
