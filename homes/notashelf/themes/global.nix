{
  osConfig,
  pkgs,
  ...
}: let
  cfg = osConfig.modules.style;
in {
  # cursor theme
  home = {
    pointerCursor = {
      package = cfg.pointerCursor.package; #pkgs.bibata-cursors;
      name = "${cfg.pointerCursor.name}"; #"Bibata-Modern-Classic";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  };

  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [fcitx5-mozc];
}