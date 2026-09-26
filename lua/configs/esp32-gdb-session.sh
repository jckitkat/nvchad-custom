#!/usr/bin/env bash
# Plain interactive GDB session against the ESP-WROVER-KIT over its onboard
# FT2232H JTAG, bypassing nvim-dap/cpptools entirely. Use this when you need
# reliable breakpoints - cpptools' DAP bridge has confirmed bugs reporting
# breakpoint hits for this FreeRTOS/Xtensa remote-debug combination.
set -uo pipefail

PROJECT_DIR="$(pwd)"
ELF="$PROJECT_DIR/.pio/build/esp-wrover-kit/firmware.elf"
OPENOCD="$HOME/.platformio/packages/tool-openocd-esp32/bin/openocd"
OPENOCD_SCRIPTS="$HOME/.platformio/packages/tool-openocd-esp32/share/openocd/scripts"
GDB="$HOME/.platformio/packages/tool-xtensa-esp-elf-gdb/bin/xtensa-esp32-elf-gdb"
BOARD_CFG="board/esp32-wrover-kit-3.3v.cfg"
OPENOCD_LOG="/tmp/esp32-openocd-nvim-gdb-session.log"

if [ ! -f "$ELF" ]; then
  echo "No firmware.elf at $ELF - run 'pio run' (or 'pio run -t upload') first." >&2
  exit 1
fi

"$OPENOCD" -s "$OPENOCD_SCRIPTS" -f "$BOARD_CFG" >"$OPENOCD_LOG" 2>&1 &
OPENOCD_PID=$!
trap 'kill "$OPENOCD_PID" 2>/dev/null' EXIT

echo "Starting OpenOCD (pid $OPENOCD_PID), waiting for the gdb server..."
for _ in $(seq 1 50); do
  if grep -q "Listening on port 3333 for gdb connections" "$OPENOCD_LOG" 2>/dev/null; then
    break
  fi
  if ! kill -0 "$OPENOCD_PID" 2>/dev/null; then
    echo "OpenOCD exited early - log follows:" >&2
    cat "$OPENOCD_LOG" >&2
    exit 1
  fi
  sleep 0.2
done

"$GDB" -q \
  -ex "set remotetimeout 10" \
  -ex "target remote :3333" \
  -ex "monitor reset halt" \
  -ex "maintenance flush register-cache" \
  -ex "thbreak app_main" \
  -ex "continue" \
  "$ELF"
