{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    shell = "/opt/homebrew/bin/fish";
    keyMode = "vi";
    extraConfig = builtins.concatStringsSep "\n" [
      (builtins.readFile ./tmux.conf)
      "run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux"
    ];
    terminal = "xterm-256colors";
    plugins = with pkgs; [
      tmuxPlugins.resurrect
      tmuxPlugins.net-speed
      tmuxPlugins.mode-indicator
      tmuxPlugins.yank
      tmuxPlugins.catppuccin
      tmuxPlugins.cpu
      # tmux-mem-cpu-load
    ];
  };
}
