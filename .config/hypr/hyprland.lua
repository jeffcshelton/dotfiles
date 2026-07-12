-- Jupiter monitor 1.5x scaling.
hl.monitor({
  output = "HDMI-A-1",
  mode = "preferred",
  position = "auto",
  scale = 1.5,
})

-- Ceres display 2x scaling.
hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "auto",
  scale = 2,
})

-----------------
--- AUTOSTART ---
-----------------

hl.on("hyprland.start", function()
  hl.exec_cmd("clipse -listen")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("udiskie")

  -- Generate Waybar config and then start it.
  hl.exec_cmd("make -C ~/.config/waybar")
  hl.exec_cmd("waybar")
end)

-----------------------------
--- ENVIRONMENT VARIABLES ---
-----------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- NVIDIA support.
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

---------------------
--- LOOK AND FEEL ---
---------------------

hl.config({
  general = {
    allow_tearing = false,
    border_size = 2,
    col = {
      active_border = {
        colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
        angle = 45,
      },
      inactive_border = "rgba(595959aa)",
    },
    gaps_in = 5,
    gaps_out = 20,
    layout = "dwindle",
    resize_on_border = false,
  },

  decoration = {
    active_opacity = 1.0,
    inactive_opacity = 0.95,
    rounding = 10,

    shadow = {
      color = "rgba(1a1a1aee)",
      enabled = true,
      range = 4,
      render_power = 3,
    },

    blur = {
      enabled = true,
      passes = 1,
      size = 3,
      vibrancy = 0.1696,
    },
  },

  ecosystem = {
    no_update_news = true,
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
  },

  xwayland = {
    force_zero_scaling = true,
  },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-------------
--- INPUT ---
-------------

hl.config({
  input = {
    follow_mouse = 1,
    kb_layout = "thock",
    natural_scroll = true,
    sensitivity = 0,

    touchpad = {
      clickfinger_behavior = true,
      natural_scroll = true,
      scroll_factor = 0.2,
    },
  },
})

hl.device({
  name = "apple-spi-trackpad",
  sensitivity = 0.0,
})

-------------------
--- KEYBINDINGS ---
-------------------

local browser = "firefox"
local explorer = "nautilus --new-window --no-desktop"
local launcher = "rofi -show drun"
local mod = "SUPER"
local screenshot = 'grim -g "$(slurp)"'
local screenshot_to_clipboard = screenshot .. " - | wl-copy"
local terminal = "ghostty"

hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(explorer))
hl.bind(mod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + G", hl.dsp.exec_cmd(screenshot))
hl.bind(mod .. " + SHIFT + G", hl.dsp.exec_cmd(screenshot_to_clipboard))
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + S", hl.dsp.exec_cmd("spotify"))
hl.bind(mod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + V", hl.dsp.exec_cmd(terminal .. " -e 'clipse'"))
hl.bind(mod .. " + escape", hl.dsp.exit())
hl.bind(mod .. " + space", hl.dsp.exec_cmd(launcher))

-- Move focus with SUPER + arrow keys.
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))

-- Switch workspaces with SUPER + [0-9], or move windows with SUPER + SHIFT + [0-9].
for workspace = 1, 10 do
  local key = workspace % 10
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

-- Scroll through existing workspaces with SUPER + scroll.
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with SUPER + LMB/RMB and dragging.
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Bind play, pause, next, and previous.
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------

-- Ignore maximize requests from apps.
hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland.
hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

-- Clipse-specific rules.
hl.window_rule({
  name = "float-clipse",
  match = { class = "clipse" },
  float = true,
})

hl.window_rule({
  name = "size-clipse",
  match = { class = "clipse" },
  size = "622 652",
})
