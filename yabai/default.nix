{ ... }: {
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {

      layout = "bsp";
      top_padding = 0;
      bottom_padding = 0;
      left_padding = 0;
      right_padding = 0;
      window_gap = 0;
      mouse_follows_focus = "on";
      focus_follows_mouse = "off";
      split_ratio = 0.382;
      auto_balance = "off";
      external_bar = "all:0:26";
    };
    extraConfig = ''
      yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
      yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
      yabai -m rule --add label="System Settings" app="^System Settings$" manage=off
      yabai -m rule --add label="App Store" app="^App Store$" manage=off
      yabai -m rule --add label="Activity Monitor" app="^Activity Monitor$" manage=off
      yabai -m rule --add label="KeePassXC" app="^KeePassXC$" manage=off
      yabai -m rule --add label="Calculator" app="^Calculator$" manage=off
      yabai -m rule --add label="Dictionary" app="^Dictionary$" manage=off
      yabai -m rule --add label="mpv" app="^mpv$" manage=off
      yabai -m rule --add label="The Unarchiver" app="^The Unarchiver$" manage=off
      yabai -m rule --add label="Transmission" app="^Transmission$" manage=off
      yabai -m rule --add label="Darktable" app="^darktable$" manage=off
    '';
  };

}
