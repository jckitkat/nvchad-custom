-- ESP-WROVER-KIT debugging via its onboard FT2232H JTAG.
-- xtensa-esp32-elf-gdb (v12.1) has no native DAP support, so we bridge
-- DAP <-> GDB/MI with cpptools' OpenDebugAD7 (installed via :MasonInstall cpptools).
-- OpenDebugAD7 also spawns/kills OpenOCD itself via debugServerPath/debugServerArgs.

local dap = require "dap"

local pio_packages = os.getenv "HOME" .. "/.platformio/packages"
local openocd_bin = pio_packages .. "/tool-openocd-esp32/bin/openocd"
local openocd_scripts = pio_packages .. "/tool-openocd-esp32/share/openocd/scripts"
local gdb_bin = pio_packages .. "/tool-xtensa-esp-elf-gdb/bin/xtensa-esp32-elf-gdb"

dap.adapters.cppdbg = {
  id = "cppdbg",
  type = "executable",
  command = vim.fn.stdpath "data" .. "/mason/bin/OpenDebugAD7",
}

dap.configurations.cpp = {
  {
    name = "ESP-WROVER-KIT (OpenOCD + GDB)",
    type = "cppdbg",
    request = "launch",
    program = function()
      return vim.fn.getcwd() .. "/.pio/build/esp-wrover-kit/firmware.elf"
    end,
    cwd = "${workspaceFolder}",
    MIMode = "gdb",
    miDebuggerPath = gdb_bin,
    miDebuggerServerAddress = "localhost:3333",
    debugServerPath = openocd_bin,
    -- The custom .cfg (not the stock board file directly) disables OpenOCD's
    -- FreeRTOS thread awareness. See esp32-openocd-no-rtos.cfg for why:
    -- in short, cpptools/MIEngine hardcodes an assumption that the first
    -- GDB thread has id "1", which is false once FreeRTOS task-awareness
    -- reports TCB addresses as thread ids, and it then silently drops
    -- "stopped" events (or errors "Failed to find thread 1 for break
    -- event") instead of reporting breakpoint hits to nvim-dap.
    debugServerArgs = "-s " .. openocd_scripts .. " -f " .. vim.fn.stdpath "config" .. "/lua/configs/esp32-openocd-no-rtos.cfg",
    serverStarted = "Listening on port 3333 for gdb connections",
    filterStdout = true,
    filterStderr = true,
    serverLaunchTimeout = 20000,
    -- true: wait after postRemoteConnectCommands and report that halt as a
    -- proper "stopped" event instead of MIEngine silently auto-continuing
    -- (which - independent of the thread-id fix above - never reports a
    -- breakpoint hit that happens during its own implicit post-launch
    -- continue). Press continue/F5 once connected to run to your
    -- breakpoints; those go through the normal path and DO get reported.
    stopAtEntry = true,
    setupCommands = {
      { text = "set remotetimeout 10" },
    },
    -- Needs the "target remote" connection already up, which cpptools only
    -- guarantees after miDebuggerServerAddress connects (setupCommands runs
    -- too early and "monitor" is rejected: "not supported by this target").
    postRemoteConnectCommands = {
      { text = "monitor reset halt" },
      { text = "maintenance flush register-cache" },
    },
  },
}
dap.configurations.c = dap.configurations.cpp
