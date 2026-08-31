{
  # The token comes from the sops secret (duckdns_token), read by the agent.
  # The agent runs as the home user, so it can read its own sops secret file.
  services.duckdns.enable = true;
  services.duckdns.domain = "tony-yiyi";
  services.duckdns.interval = 300;
  services.duckdns.logPath = "/Users/tony/Library/Logs/duckdns.log";
}
