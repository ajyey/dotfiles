local wezterm = require 'wezterm'

-- Approximate Kitty's slanted tab style with Nerd Font half-triangle glyphs.
-- WezTerm's retro tab bar is cell-based, so each slanted edge occupies one cell.
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  -- Rose Pine Moon colors for the normal, active, and hovered tab states.
  local background = '#2a273f'
  local foreground = '#908caa'

  if tab.is_active then
    background = '#c4a7e7'
    foreground = '#191724'
  elseif hover then
    background = '#393552'
    foreground = '#e0def4'
  end

  -- Internal separator cells use a visible Rose Pine highlight instead of the
  -- tab bar's base color. Reserve two edge cells and two title-padding cells.
  local separator_background = '#393552'
  local numbered_title = string.format('%d: %s', tab.tab_index + 1, tab.active_pane.title)
  local title = wezterm.truncate_right(numbered_title, max_width - 4)
  local elements = {}

  -- Skip the first tab's leading edge so the tab strip starts flush left.
  -- U+E0BA is the upper-right Powerline triangle that forms the left slant.
  if tab.tab_index > 0 then
    table.insert(elements, { Background = { Color = separator_background } })
    table.insert(elements, { Foreground = { Color = background } })
    table.insert(elements, { Text = '\u{e0ba}' })
  end

  table.insert(elements, { Background = { Color = background } })
  table.insert(elements, { Foreground = { Color = foreground } })
  table.insert(elements, { Text = ' ' .. title .. ' ' })

  -- WezTerm tab indices are zero-based while Lua arrays are one-based, hence
  -- the +2 lookup. The final edge uses the base bar color so it blends away;
  -- internal edges retain the visible separator color. U+E0BC forms the right slant.
  local trailing_background = tabs[tab.tab_index + 2] and separator_background or '#191724'
  table.insert(elements, { Background = { Color = trailing_background } })
  table.insert(elements, { Foreground = { Color = background } })
  table.insert(elements, { Text = '\u{e0bc}' })

  return elements
end)

return {
  apply = function(config)
    -- ====================================================================
    -- Appearance & Theme
    -- ====================================================================
    config.color_scheme = 'Noctalia'
    -- Match Kitty's primary font and observed fallback order.
    config.font = wezterm.font_with_fallback {
      'Noto Sans Mono',
      'FiraCode Nerd Font',
      'DejaVu Sans Mono',
    }
    config.font_size = 15.0

    -- Override highlight/selection colors for better contrast
    config.colors = {
      selection_fg = '#191724', -- Dark background color for text
      selection_bg = '#c4a7e7', -- Iris (Purple) for high contrast highlight
      -- Keep WezTerm's base tab colors aligned with the custom formatter above.
      tab_bar = {
        background = '#191724',
        active_tab = {
          bg_color = '#c4a7e7',
          fg_color = '#191724',
          intensity = 'Bold',
        },
        inactive_tab = {
          bg_color = '#2a273f',
          fg_color = '#908caa',
        },
        inactive_tab_hover = {
          bg_color = '#393552',
          fg_color = '#e0def4',
        },
      },
    }

    -- ====================================================================
    -- Window & UI Settings
    -- ====================================================================
    config.window_background_opacity = 0.97
    config.macos_window_background_blur = 50
    config.window_padding = { left = '0.5cell', right = '0.5cell', top = '0.5cell', bottom = '0.5cell' }
    config.window_close_confirmation = "NeverPrompt"

    -- Use the cell-based bar required by format-tab-title, place it at the top,
    -- hide it for a single tab, and remove the built-in new-tab button.
    config.use_fancy_tab_bar = false
    config.tab_bar_at_bottom = false
    config.hide_tab_bar_if_only_one_tab = true
    config.show_new_tab_button_in_tab_bar = false
    config.tab_max_width = 32

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
    config.alternate_buffer_wheel_scroll_speed = 1

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
