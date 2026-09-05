# herdr-mirror/hosts.toml — per-host herdr-mirror host list.
#
# herdr-mirror reads ~/.config/herdr-mirror/hosts.toml (see the "Configuration"
# section of https://github.com/nikok6/herdr-mirror). Each [hosts.<alias>]
# entry mirrors one remote herdr server; `target` is anything ssh accepts,
# so we use the ssh alias from this machine's ssh config.
#
# The host list is derived from programs.ssh.settings, so each machine in the
# flake writes its own hosts.toml from its own ssh config:
#   - wutongs-MacBook-Air uses ssh/air.nix
#   - Tonys-Mac-mini-M4 uses ssh/mini.nix
# github.com is a git remote, not a herdr host, and is excluded.

{ config, lib, ... }:

let
  sshSettings = config.programs.ssh.settings or { };

  # ssh alias for an entry: its `host` field, falling back to the Nix key.
  aliasOf = name: value: value.host or name;

  # Keep every machine entry; drop github.com (git remote, not herdr).
  machines = lib.filterAttrs (name: value: aliasOf name value != "github.com") sshSettings;

  hostBlock = name: value:
    let alias = aliasOf name value; in
    "[hosts.${alias}]\n" + "target = \"${alias}\"\n";

  tomlText =
    "# Managed by nix-darwin (herdr/herdr-mirror-hosts.nix) — generated from the\n"
    + "# local ssh config; edit programs.ssh.settings instead of this file.\n"
    + builtins.concatStringsSep "\n" (lib.attrValues (lib.mapAttrs hostBlock machines));
in
{
  home.file.".config/herdr-mirror/hosts.toml" = {
    text = tomlText;
  };
}
