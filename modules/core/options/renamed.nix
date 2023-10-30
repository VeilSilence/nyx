{lib, ...}: let
  inherit (lib) mkRenamedOptionModule;
in {
  imports = [
    (mkRenamedOptionModule ["modules" "device" "yubikeySupport"] ["modules" "system" "yubikeySupport"])
    (mkRenamedOptionModule ["modules" "system" "security" "secureBoot"] ["modules" "system" "boot" "secureBoot"])
    (mkRenamedOptionModule ["modules" "usrEnv" "autologin"] ["modules" "system" "autoLogin"])
    (mkRenamedOptionModule ["modules" "system" "services" "gitea" "enable"] ["modules" "system" "services" "forgejo" "enable"])
  ];
}