-- Pangramas de teste:
-- À noite, vovô Kowalsky vê o ímã cair no pé do pinguim queixoso e vovó põe açúcar no chá de tâmaras do jabuti feliz.
-- à NOITE, VOVÔ kOWALSKY VÊ O ÍMÃ CAIR NO PÉ DO PINGUIM QUEIXOSO E VOVÓ PÕE AÇÚCAR NO CHÁ DE TÂMARAS DO JABUTI FELIZ.

-- [=[
local TEMA_CLARO = true

local my_defaults = {
  strip_trailing_spaces = true,
  tab_width = 2,
  max_line_len = 100,
  view_ws = view.WS_INVISIBLE,
  highlight_words = textadept.editing.HIGHLIGHT_SELECTED,
  theme = TEMA_CLARO and 'base16-gruvbox-light-soft' or  'base16-bright',
  --theme_props = {font = 'Terminus (TTF)' .. (WIN32 and ' for Windows' or ''), size = 12}, --
  --theme_props = {font = 'Unifont', size = 12},                 -- good pixel font
  --theme_props = {font = 'basis33', size = 12},                 -- good tiny pixel font
  --theme_props = {font = 'PxPlus IBM BIOS-2y', size = 12},      -- confusing
  --theme_props = {font = 'PxPlus AmstradPC1512-2y', size = 12}, -- cleaner than IBM BIOS, however is non-serif
  --theme_props = {font = 'Perfect DOS VGA 437 Win', size = 12}, --
  --theme_props = {font = 'unscii', size = 12},                  -- not render well
  --theme_props = {font = 'Luxi Mono', size = 8},                 --
  --theme_props = {font = 'Go Mono', size = 10},                 --
  theme_props = {font = 'JetBrains Mono NL', size = 9},                 --
  --theme_props = {font = 'CozetteVector', size = 9},            -- good tiny pixel font!
  --theme_props = {font = '04b03', size = 6*ESCALA},        --
  --theme_props = {font = 'DejaVU Sans Mono', size = 11},        --
  --theme_props = {font = 'hack', size = 10},                    --

  -- Codeman38's font
  --theme_props = {font = 'Press Start 2P', size = 6},            -- good tiny pixel font!
  --theme_props = {font = 'PC Senior', size = 6},            -- good tiny pixel font!
  --theme_props = {font = 'DeluxeFont', size = 6},            -- good tiny pixel font!
  --theme_props = {font = 'Kongtext', size = 6},            -- good tiny pixel font!
}

local function open_or_close_by_lexer(lexer, lang)
  return lexer == lang and 'open' or 'close'
end

local function andre_la()
  if not CURSES then
    view:set_theme(my_defaults.theme, my_defaults.theme_props)
  end

  textadept.editing.strip_trailing_spaces = my_defaults.strip_trailing_spaces
  textadept.editing.highlight_words = my_defaults.highlight_words

  buffer.tab_width = my_defaults.tab_width
  buffer.use_tabs  = my_defaults.use_tabs
  view.view_ws  = my_defaults.view_ws

  view.edge_column = my_defaults.max_line_len
  view.edge_mode = buffer[CURSES and "EDGE_BACKGROUND" or "EDGE_LINE"]
end

local nautilus_opened = false
local function nautilus()
  if nautilus_opened then
    return
  end

  nautilus_opened = true

  local tools_menu = textadept.menu.menubar[_L['_Buffer']]
  tools_menu[#tools_menu+1] = {
    "Open in _Nautilus",
    function()
      local working_path = buffer.filename:match("^(.*/).*")
      os.execute('nautilus ' .. working_path)
    end
  }
end

-- _M.lsp = require 'lsp'
-- _M.lsp.log_rpc = true

require 'ta-nelua'
local function nelua(lexer)
  if lexer ~= 'nelua' then return end

  view.edge_column = 120
end

local function csharp(lexer)
  local is_csharp = lexer == "csharp"
  if not is_csharp then return end

  buffer.tab_width = 4
end

local function lua(lexer)
  local is_lua = lexer == "lua"
  if not is_lua then return end

  --buffer.tab_width = is_lua and 3 or my_defaults.tab_width
  view.edge_column = 120
end

local function markdown(lexer)
  local is_markdown = lexer == 'markdown'
  if not is_markdown then return end

  textadept.editing.strip_trailing_spaces = false
  buffer.tab_width = 4
end

local function luacheck(lexer)
  _M.ta_luacheck = require 'ta-luacheck'
  _M.ta_luacheck[open_or_close_by_lexer(lexer, 'lua')]()
end

local function unity(lexer)
  if WIN32 and lexer == 'csharp' then
    _M.ta_unity = require 'ta-unity'
  end
end

nautilus()

events.connect(events.LEXER_LOADED, function(lexer)
  andre_la()

  csharp(lexer)
  nelua(lexer)
  lua(lexer)
  markdown(lexer)
  luacheck(lexer)
  gdscript(lexer)
  --unity(lexer)
end)
--]=]
