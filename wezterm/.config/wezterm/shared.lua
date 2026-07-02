local wezterm = require 'wezterm'

return {
  apply = function(config)
    -- ====================================================================
    -- Appearance & Theme
    -- ====================================================================
    config.color_scheme = 'rose-pine-moon'
    config.font_size = 15.0

    -- Override highlight/selection colors for better contrast
    config.colors = {
      selection_fg = '#191724', -- Dark background color for text
      selection_bg = '#c4a7e7', -- Iris (Purple) for high contrast highlight
    }

    -- ====================================================================
    -- Window & UI Settings
    -- ====================================================================
    config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
    config.window_background_opacity = 0.8
    config.macos_window_background_blur = 50
    config.window_padding = { left = '0.5cell', right = '0.5cell', top = '0.5cell', bottom = '0.5cell' }
    config.window_close_confirmation = "NeverPrompt"

    config.window_frame = {
      font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
      font_size = 13.0,
    }

    -- ====================================================================
    -- Behavior
    -- ====================================================================
    config.warn_about_missing_glyphs = false

    config.default_cursor_style = 'BlinkingBar'
    config.scrollback_lines = 100000

    -- Dim inactive panes
    config.inactive_pane_hsb = {
      saturation = 0.0,
      brightness = 0.5,
    }

    -- Allow Left Option (Alt) to function as a true Meta/Alt key in the terminal
    -- instead of typing macOS special characters (like † or ∑). 
    -- This is strictly required for our Zellij Alt-key navigation!
    config.send_composed_key_when_left_alt_is_pressed = false
  end
}
