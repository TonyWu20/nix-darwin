{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    shell = "/opt/homebrew/bin/fish";
    keyMode = "vi";
    extraConfig = builtins.concatStringsSep "\n" [
      (builtins.readFile ./tmux.conf)
      "set -g visual-bell both"
      "set -g bell-action other"
      "setw -g monitor-activity on"
      ''
        set -g pane-active-border-style "#{?pane_input_off,fg=red,fg=green}"
        set -g pane-border-status top
        set -g pane-border-format "#{?pane_input_off,#[fg=white,bg=red,bold] LOCKED ,#[default]#{pane_index}} #{pane_current_command}"
        # Toggle input and force a border refresh (Prefix + X)
        bind X run-shell -C "select-pane -#{?pane_input_off,e,d}; refresh-client -S"
      ''
      "run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux"
    ];
    terminal = "tmux-256color";
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
