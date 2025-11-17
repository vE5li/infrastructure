{
  pkgs,
  lib,
  config,
  neovim,
  ...
}: let
  python3 = pkgs.python3.withPackages (ps: with ps; [pynvim]);

  nvim-merge = pkgs.writeScriptBin "nvim-merge" ''
    #!${lib.getExe python3}
    """Edit a file in the host nvim instance."""

    import os
    import sys
    import time
    import neovim

    # Remove this script from the args.
    args = sys.argv[1:]

    # Try to get the socket of a running Neovim instance.
    addr = os.environ.get("NVIM", None)

    # If there is no other instance of Neovim running, start a new one.
    if not addr:
        os.execvp('nvim', ['nvim'] + args)

    # Attach to the existing Neovim instance.
    nvim = neovim.attach("socket", path=addr)

    # If we didn't provide any arguments but are connected to socket, set a default file name.
    default_file = False
    if not args:
        args = ["new_file"]
        default_file = True

    # Open all arguments passed to the script as files in our new instance.
    # TODO: This could use some additional parsing to make sure we don't open flags as files.
    nvim.vars['files_to_edit'] = list(reversed(args))
    for _ in args:
        nvim.command('exe "edit ".remove(g:files_to_edit, 0)')


    def find_buffer(name):
        # Get a list of all buffers.
        buffers = nvim.api.list_bufs()

        for buffer in buffers:
            try:
                buffer_name = nvim.api.buf_get_name(buffer)
            except:
                continue

            if buffer_name == name:
                return True

        return False

    # Halt the script until we are done editing the file.
    if not default_file:
        while find_buffer(args[0]):
            time.sleep(0.2)
  '';

  # Script to create a new instance with neovim and fish running
  nvim-terminal = pkgs.writeShellScriptBin "nvim-terminal" ''
    nvim +"lua (function()
        vim.cmd('term')
        vim.cmd('keepalt file initial.terminal')
        vim.cmd('norm! i')
    end)()"
  '';
in {
  options.role-configuration.neovim = with lib; {
    include-language-servers = mkOption {
      description = "Include language servers";
      type = types.bool;
      default = true;
    };
  };

  config = {
    home.packages = lib.flatten (with pkgs;
      [
        nvim-merge
        nvim-terminal
        # For copying and pasting over SSH.
        # See: https://github.com/lemonade-command/lemonade/issues/44#issuecomment-2306679022 for an alternative.
        lemonade
        # For Telescope live grep
        ripgrep
      ]
      ++ lib.optional config.role-configuration.neovim.include-language-servers [
        pkgs.lua-language-server
        kotlin-language-server
        typescript-language-server
        nil
        # Python with LSP.
        (pkgs.python3.withPackages (ps: with ps; [python-lsp-server]))
      ]);

    home.sessionVariables = {
      EDITOR = lib.getExe nvim-merge;
    };

    programs.neovim = {
      enable = true;
      package = neovim.packages.${pkgs.pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
        treesitter-parsers = {};
      };
    };

    xdg.configFile."nvim/" = {
      source = ../neovim-configuration;
      recursive = true;
      # Clean up compiled lua files. This is a workaround for lazy.nvim not recompiling when symlinks change.
      onChange = "rm -f ${config.xdg.cacheHome}/nvim/luac/%2fhome%2f${config.role-configuration.user-name}%2f.config*.luac";
    };

    xdg.configFile."nvim/lua/colors.lua" = {
      text = ''
        return {
            base00 = '#${config.colorScheme.palette.base00}',
            base01 = '#${config.colorScheme.palette.base01}',
            base02 = '#${config.colorScheme.palette.base02}',
            base03 = '#${config.colorScheme.palette.base03}',
            base04 = '#${config.colorScheme.palette.base04}',
            base05 = '#${config.colorScheme.palette.base05}',
            base06 = '#${config.colorScheme.palette.base06}',
            base07 = '#${config.colorScheme.palette.base07}',
            base08 = '#${config.colorScheme.palette.base08}',
            base09 = '#${config.colorScheme.palette.base09}',
            base0A = '#${config.colorScheme.palette.base0A}',
            base0B = '#${config.colorScheme.palette.base0B}',
            base0C = '#${config.colorScheme.palette.base0C}',
            base0D = '#${config.colorScheme.palette.base0D}',
            base0E = '#${config.colorScheme.palette.base0E}',
            base0F = '#${config.colorScheme.palette.base0F}',
        }
      '';
      # Clean up compiled lua files. This is a workaround for lazy.nvim not recompiling when symlinks change.
      onChange = "rm -f ${config.xdg.cacheHome}/nvim/luac/%2fhome%2f${config.role-configuration.user-name}%2f.config%2fnvim%2flua%2fcolors.luac";
    };
  };
}
