# Fixed procs cable for television.
#
# Replaces the built-in procs cable that `tv update-channels` writes to
# ~/.config/television/cable/procs.toml. That built-in source
# (`ps -e -o pid=,ucomm= | awk '{print $1, $2}'`) displays only the
# process name (`display = "{split: :1}"`). A typed query can then
# match only the name. It cannot match the PID, the user, or an
# argument of the command line.
#
# This cable bases its source on `ps aux` instead:
#
#   source.command emits one `ps aux` line per process, with the full
#   command line. `NR>1` drops the header line. `gsub(/ +/, " ")`
#   reduces runs of spaces to one space. The space-delimited field
#   indices are then stable: user=0, pid=1, command from 10.
#
#   source.display renders each entry as "PID USER COMMAND". The PID
#   and the full command line stay visible and matchable in the
#   results row. The %CPU, %MEM, TTY, STAT, START, and TIME columns
#   leave the row. The preview still shows them via `ps -p`.
#
#   source.output keeps the PID. A selection hands the PID to the
#   shell integration. The kill, term, stop, and cont actions keep
#   the built-in keybindings and their `kill` commands, re-indexed
#   to the new row layout.
#
# procps renders a newline inside a process argument as a space in
# `ps aux` output. An entry therefore stays one line.
#
# `tv update-channels` skips files that already exist, so this cable
# survives channel updates; only `tv update-channels --force` would
# overwrite it.

{ ... }:

{
  programs.television.channels."procs" = {
    metadata = {
      name = "procs";
      description = "A channel to find and manage running processes";
      requirements = [ "ps" "awk" ];
    };

    source = {
      # one ps aux line per process, header dropped, padding reduced
      command = "ps aux | awk 'NR>1 { gsub(/ +/, \" \"); print }'";
      # row shows PID USER COMMAND, all of it fuzzy-matchable
      display = "{split: :1} {split: :0} {split: :10..}";
      # a selection hands the PID to the shell integration
      output = "{split: :1}";
    };

    preview = {
      command = "ps -p '{split: :1}' -o user,pid,ppid,state,%cpu,%mem,command | fold";
    };

    keybindings = {
      "ctrl-k" = "actions:kill";
      f2 = "actions:term";
      "ctrl-s" = "actions:stop";
      "ctrl-c" = "actions:cont";
    };

    actions = {
      kill = {
        description = "Kill the selected process (SIGKILL)";
        command = "kill -9 {split: :1}";
        mode = "execute";
      };
      term = {
        description = "Terminate the selected process (SIGTERM)";
        command = "kill -15 {split: :1}";
        mode = "execute";
      };
      stop = {
        description = "Stop/pause the selected process (SIGSTOP)";
        command = "kill -STOP {split: :1}";
        mode = "fork";
      };
      cont = {
        description = "Continue/resume the selected process (SIGCONT)";
        command = "kill -CONT {split: :1}";
        mode = "fork";
      };
    };
  };
}
