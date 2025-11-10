{
  pkgs,
  config,
  lib,
  ...
}: let
  python3 = pkgs.python3.withPackages (ps: with ps; [pynvim]);

  nvim-autocwd = pkgs.writeScriptBin "nvim-autocwd" ''
    #!${lib.getExe python3}
    import json
    import neovim
    import os
    import subprocess
    from pathlib import Path

    addr = os.environ.get("NVIM", None)
    nvim = neovim.attach("socket", path=addr)
    working_directory = os.getcwd()

    try:
        subprocess.run(["cargo", "--version"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True, timeout=1)
        result = subprocess.run(
            ["cargo", "locate-project", "--workspace"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            check=True,
            text=True
        )
        project_root = json.loads(result.stdout)["root"]
        working_directory = str(Path(project_root).parent)
    except Exception:
        pass # silently ignore all errors

    nvim.vars['__autocd_cwd'] = working_directory
    # NOTE: Use `lcd` for changing working directory per window
    # nvim.command('execute "lcd" fnameescape(g:__autocd_cwd)')
    nvim.command('execute "cd" fnameescape(g:__autocd_cwd)')
    del nvim.vars['__autocd_cwd']
  '';

  nvim-autopath = pkgs.writeScriptBin "nvim-autopath" ''
    #!${lib.getExe python3}
    import neovim
    import os

    addr = os.environ.get("NVIM", None)
    nvim = neovim.attach("socket", path=addr)

    nvim.exec_lua('vim.fn.setenv("PATH", "' + os.environ["PATH"] + '")')
  '';
in {
  # j command in Fish.
  programs.autojump.enable = true;

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fish.enable = true;

  programs.fish.shellAbbrs = {
    gt = "git checkout";
  };

  programs.fish.shellAliases = {
    ls = "${lib.getExe pkgs.eza} --icons";
    list-generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    delete-old-generations = "sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system";
  };

  programs.fish.interactiveShellInit = ''
    [ -f /usr/share/autojump/autojump.fish ]; and source /usr/share/autojump/autojump.fish

    # General settings
    set fish_greeting
    set fish_key_bindings fish_default_key_bindings

    # Colors
    set fish_color_autosuggestion cyan
    set fish_color_cancel red
    set fish_color_command ${config.colorScheme.palette.base09}
    set fish_color_comment yellow
    set fish_color_cwd green
    set fish_color_cwd_root red
    set fish_color_end red
    set fish_color_error red
    set fish_color_escape red
    set fish_color_history_current --bold
    set fish_color_host normal
    set fish_color_host_remote normal
    set fish_color_keyword normal
    set fish_color_match --background=blue
    set fish_color_normal normal
    set fish_color_operator blue
    set fish_color_option normal
    set fish_color_param ${config.colorScheme.palette.base05}
    set fish_color_quote yellow
    set fish_color_redirection cyan
    set fish_color_search_match yellow --background=black
    set fish_color_selection white --bold --background=black
    set fish_color_status red
    set fish_color_user green
    set fish_color_valid_path green
    set fish_pager_color_background \x1d
    set fish_pager_color_completion normal
    set fish_pager_color_description ${config.colorScheme.palette.base09}
    set fish_pager_color_prefix normal --bold --underline
    set fish_pager_color_progress white --background=cyan
    set fish_pager_color_secondary_background normal
    set fish_pager_color_secondary_completion normal
    set fish_pager_color_secondary_description normal
    set fish_pager_color_secondary_prefix normal
    set fish_pager_color_selected_background --background=black
    set fish_pager_color_selected_completion normal
    set fish_pager_color_selected_description normal
    set fish_pager_color_selected_prefix normal

    # When chaning the working directory, change the cwd of Neovim
    function set_nvim_pwd_after_change --on-variable PWD
        if set -q NVIM
            set -l green (set_color -o green)
            set -l normal (set_color normal)
            set -l update_text " Changing editor working directory"
            echo "$green$update_text$normal"

            ${lib.getExe nvim-autocwd}
        end
    end

    # When $PATH changes, send it to Neovim
    function set_nvim_path_on_path_change --on-variable PATH
        if set -q NVIM
            set -l green (set_color -o green)
            set -l normal (set_color normal)
            set -l update_text " Updating editor PATH from the shell"
            echo "$green$update_text$normal"

            ${lib.getExe nvim-autopath}
        end
    end

    # Helper function to get the actual name of a font
    function font_name
        fc-list | grep $argv
    end

    # Helper function to host stuff for Simon
    function host-for-simon
        docker run -v $(pwd):/static -p 8080:80 flashspys/nginx-static
    end

    # Helper function to create a nix shell
    function ns
        nix shell nixpkgs#$argv
    end

    # Taken from https://github.com/isacikgoz/sashimi
    function fish_prompt
      set -l last_status $status
      set -l cyan (set_color -o cyan)
      set -l yellow (set_color -o yellow)
      set -g red (set_color -o red)
      set -g blue (set_color -o blue)
      set -l green (set_color -o green)
      set -l orange (set_color "#${config.colorScheme.palette.base09}")
      set -g normal (set_color normal)

      set -l ahead
      set -g whitespace ' '

      set -l status_icon ""

      # Broken since switching to `nix shell`.
      # See https://github.com/NixOS/nix/issues/6677.
      if test -n "$IN_NIX_SHELL"
        set status_icon ""
      end

      set -l shell_level_threshold 4
      set -l ssh_prefix ""
      if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]
        set -l username (whoami)
        set -l my_hostname (prompt_hostname)
        set ssh_prefix "$indicator_color◆ $username $green󰁥 $my_hostname "
        set shell_level_threshold 3
      end

      set -l shell_level ""
      if [ $SHLVL -ge $shell_level_threshold ]
        set indicators (string repeat -n (math "$SHLVL - $shell_level_threshold + 1") "+")
        set shell_level "$green$indicators$whitespace"
      end

      if test $last_status = 0
        # Broken since switching to `nix shell`.
        # See https://github.com/NixOS/nix/issues/6677.
        if test -n "$IN_NIX_SHELL"
          set indicator_color "$blue"
        else
          set indicator_color "$cyan"
        end

        set initial_indicator "$indicator_color◆"
        set status_indicator "$indicator_color$status_icon"
      else
        set indicator_color "$red"
        set initial_indicator "$red◆ $last_status"
        set status_indicator "$red$status_icon"
      end
      set -l cwd $orange(basename (prompt_pwd))

      if [ (_jujutsu_change_id_shortest) ]
          set -l shortest (_jujutsu_change_id_shortest)
          set -l short (_jujutsu_change_id $shortest)

          set git_info "$normal jj:($red$shortest$blue$short$normal)"
      else if [ (_git_branch_name) ]
        if test (_git_branch_name) = 'main' || test (_git_branch_name) = 'master'
          set -l git_branch (_git_branch_name)
          set git_info "$normal git:($red$git_branch$normal)"
        else
          set -l git_branch (_git_branch_name)
          set git_info "$normal git:($blue$git_branch$normal)"
        end

        if [ (_is_git_dirty) ]
          set -l dirty "$yellow ✗"
          set git_info "$git_info$dirty"
        end

        set ahead (_git_ahead)
      end

      # Notify if a command took more than 5 minutes
      if [ "$CMD_DURATION" -gt 300000 ]
        echo The last command took (math "$CMD_DURATION/1000") seconds.
      end

      echo -n -s $ssh_prefix $initial_indicator $whitespace $cwd $git_info $whitespace $ahead $shell_level $status_indicator $normal $whitespace $whitespace
    end

    function _jujutsu_change_id_shortest
        echo (jj log -r @ --template 'self.change_id().shortest()' --color=never --no-graph --ignore-working-copy 2>/dev/null)
    end

    function _jujutsu_change_id
      set -l entire (jj log -r @ --template 'self.change_id().short()' --color=never --no-graph --ignore-working-copy 2>/dev/null)
      echo (string replace -r "^$argv" "" "$entire")
    end

    function _git_ahead
      set -l commits (command git rev-list --left-right '@{upstream}...HEAD' 2>/dev/null)
      if [ $status != 0 ]
        return
      end
      set -l behind (count (for arg in $commits; echo $arg; end | grep '^<'))
      set -l ahead  (count (for arg in $commits; echo $arg; end | grep -v '^<'))
      switch "$ahead $behind"
        case \'\'     # no upstream
        case '0 0'  # equal to upstream
          return
        case '* 0'  # ahead of upstream
          echo "$blue↑$normal_c$ahead$whitespace"
        case '0 *'  # behind upstream
          echo "$red↓$normal_c$behind$whitespace"
        case '*'    # diverged from upstream
          echo "$blue↑$normal$ahead $red↓$normal_c$behind$whitespace"
      end
    end

    function _git_branch_name
      echo (command git symbolic-ref HEAD 2>/dev/null | sed -e 's|^refs/heads/||')
    end

    function _is_git_dirty
      echo (command git status -s --ignore-submodules=dirty 2>/dev/null)
    end
  '';
}
