# Pico HSM build configuration
# Modify these values to customize your build
{
  # USB Vendor ID - use your own or a preset
  vid = "0x234B";

  # USB Product ID - use your own or a preset
  pid = "0x0000";

  # Board type: "pico" or "pico2"
  board = "pico2";
}

# Common VID/PID presets for reference:
# ┌──────────────┬────────┬────────┐
# │ Name         │ VID    │ PID    │
# ├──────────────┼────────┼────────┤
# │ NitroHSM     │ 0x20A0 │ 0x4230 │
# │ NitroFIDO2   │ 0x20A0 │ 0x42B1 │
# │ NitroStart   │ 0x20A0 │ 0x4211 │
# │ NitroPro     │ 0x20A0 │ 0x4108 │
# │ Nitro3       │ 0x20A0 │ 0x42B2 │
# │ Yubikey5     │ 0x1050 │ 0x0407 │
# │ YubikeyNeo   │ 0x1050 │ 0x0116 │
# │ YubiHSM      │ 0x1050 │ 0x0030 │
# │ Gnuk         │ 0x234B │ 0x0000 │
# │ GnuPG        │ 0x1209 │ 0x2440 │
# └──────────────┴────────┴────────┘
