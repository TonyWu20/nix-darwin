{
  services.sing-box.enable = true;
  services.sing-box.logPath = "/Users/tony/Library/Logs/sing-box.log";

  # VLESS + Reality server. Friend dials this with Shadowrocket (see client.md).
  # The agent runs as the home user, so no runAsUser is needed.
  services.sing-box.settings = {
    log.level = "info";
    log.timestamp = true;

    inbounds = [
      {
        type = "vless";
        tag = "vless-reality";
        listen = "::";
        listen_port = 4433;
        # The VLESS credentials are kept out of this public repo.
        # uuid, private_key, and short_id are injected at runtime from the
        # sops secrets vless_uuid / vless_private_key / vless_short_id.
        # See the launcher in sing-box/module.nix. Placeholders here.
        users = [
          {
            name = "friend";
            uuid = "";
            flow = "";
          }
        ];
        tls = {
          enabled = true;
          # Trusted SNI. Must match the client and be a GFW-allowed site.
          # apple.com is GFW-allowed and reliably completes the TLS 1.3
          # handshake that the Reality seed exchange needs.
          server_name = "www.apple.com";
          reality = {
            enabled = true;
            # TLS handshake camouflage target. Must be a TLS 1.3 site.
            handshake.server = "www.apple.com";
            handshake.server_port = 443;
            # Generated with: openssl genpkey -algorithm X25519
            # Cross-checked with the cryptography library.
            # Value is injected at runtime from the sops secret vless_private_key.
            private_key = "";
            # Injected at runtime from the sops secret vless_short_id.
            short_id = [ ];
          };
        };
      }
    ];
  };
}
