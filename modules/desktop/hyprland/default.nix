{ pkgs, lib, config, fetchzip, inputs, stdenv, ... }:
with lib;
let
  cfg = config.modules.desktop.hyprland;
  mkService = lib.recursiveUpdate {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = [ "graphical-session.target" ];
  };
  ocr = pkgs.writeShellScriptBin "ocr" ''
    #!/bin/bash
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -w 0 -b eebebed2)" /tmp/ocr.png && ${pkgs.tesseract5}/bin/tesseract /tmp/ocr.png /tmp/ocr-output && ${pkgs.wl-clipboard}/bin/wl-copy < /tmp/ocr-output.txt && ${pkgs.libnotify}/bin/notify-send "OCR" "Text copied!" && rm /tmp/ocr-output.txt -f
  '';
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    #!/bin/bash
    hyprctl keyword animation "fadeOut,0,8,slow" && ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -w 0 -b 5e81acd2)" - | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png; hyprctl keyword animation "fadeOut,1,8,slow"
  '';

in {
  options.modules.desktop.hyprland = { enable = mkEnableOption "hyprland"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      brightnessctl
      pamixer
      python39Packages.requests
      slurp
      ocr
      screenshot
      wlogout
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      wf-recorder
    ];

    home.pointerCursor = {
      package = pkgs.catppuccin-cursors;
      name = "Catppuccin-Frappe-Dark";
      size = 16;
    };
    home.pointerCursor.gtk.enable = true;

    #xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;
    home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;

    services.gammastep = {
      enable = true;
      provider = "geoclue2";
    };

    systemd.user.services = {
      swaybg = mkService {
        Unit.Description = "Wallpaper chooser";
        Service.ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${./wall.png}";
      };
    };
  };
}