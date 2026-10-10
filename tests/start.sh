#!/usr/bin/env bash

# Bridge the simulator's PTY (./uart/pty/uart) and the PTY that a terminal such
# as `screen` attaches to (./uart/pty/uart_wrapper).
socat pty,raw,echo=0,link=./uart/pty/uart pty,raw,echo=0,link=./uart/pty/uart_wrapper &
socat_pid=$!

# Clean up socat on exit. Ctrl-C is delivered to socat directly, so the signal
# traps only need to exit cleanly (status 0) so make doesn't report an error.
trap 'kill "$socat_pid" 2>/dev/null' EXIT
trap 'exit 0' INT TERM

# Give socat a moment to create the symlinks before the simulation opens them.
sleep .25
./uart/Vtop_level
