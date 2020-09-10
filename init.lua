local TEMA_CLARO = true

local my_defaults = {
   strip_trailing_spaces = true,
   tab_width = 3,
   max_line_len = 100,
   view_ws = buffer.WS_INVISIBLE,
   theme = TEMA_CLARO and 'base16-gruvbox-light-soft' or  'base16-bright',
   --theme_props = {font = 'Terminus (TTF)' .. (WIN32 and ' for Windows' or ''), fontsize = 12}, --
   --theme_props = {font = 'Unifont', fontsize = 12},                 -- good pixel font
   --theme_props = {font = 'basis33', fontsize = 12},                 -- good tiny pixel font
   --theme_props = {font = 'PxPlus IBM BIOS-2y', fontsize = 12},      -- confusing
   --theme_props = {font = 'PxPlus AmstradPC1512-2y', fontsize = 12}, -- cleaner than IBM BIOS, however is non-serif
   --theme_props = {font = 'Perfect DOS VGA 437 Win', fontsize = 12}, --
   --theme_props = {font = 'unscii', fontsize = 12},                  -- not render well
   --theme_props = {font = 'Luxi Mono', fontsize = 8},                 --
   --theme_props = {font = 'Go Mono', fontsize = 8},                 --
   theme_props = {font = 'CozetteVector', fontsize = 9},            -- good tiny pixel font!
   --theme_props = {font = '04b03', fontsize = 6*ESCALA},        --
   --theme_props = {font = 'DejaVU Sans Mono', fontsize = 11},        --
   --theme_props = {font = 'hack', fontsize = 10},                    --

   -- Codeman38's font
   --theme_props = {font = 'Press Start 2P', fontsize = 6},            -- good tiny pixel font!
   --theme_props = {font = 'PC Senior', fontsize = 6},            -- good tiny pixel font!
   --theme_props = {font = 'DeluxeFont', fontsize = 6},            -- good tiny pixel font!
   --theme_props = {font = 'Kongtext', fontsize = 6},            -- good tiny pixel font!
}

local function open_or_close_by_lexer(lexer, lang)
   return lexer == lang and 'open' or 'close'
end

local function andre_la()
   if not CURSES then
      buffer:set_theme(my_defaults.theme, my_defaults.theme_props)
   end

   textadept.editing.strip_trailing_spaces = my_defaults.strip_trailing_spaces

   buffer.tab_width = my_defaults.tab_width
   buffer.use_tabs  = my_defaults.use_tabs
   buffer.view_ws  = my_defaults.view_ws

   -- Pangramas de teste:
   -- À noite, vovô Kowalsky vê o ímã cair no pé do pinguim queixoso e vovó põe açúcar no chá de tâmaras do jabuti feliz.
   -- à NOITE, VOVÔ kOWALSKY VÊ O ÍMÃ CAIR NO PÉ DO PINGUIM QUEIXOSO E VOVÓ PÕE AÇÚCAR NO CHÁ DE TÂMARAS DO JABUTI FELIZ.
   buffer.edge_column = my_defaults.max_line_len
   buffer.edge_mode = buffer[CURSES and "EDGE_BACKGROUND" or "EDGE_LINE"]
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

require 'ta-nelua'
local function nelua(lexer)
   if lexer ~= 'nelua' then return end
   buffer.edge_column = 120
end

local function csharp(lexer)
   local is_csharp = lexer == "csharp"
   if not is_csharp then return end

   buffer.tab_width = is_csharp and 4 or my_defaults.tab_width
end

local function lua(lexer)
   local is_lua = lexer == "lua"
   if not is_lua then return end

   --buffer.tab_width = is_lua and 3 or my_defaults.tab_width
   buffer.edge_column = is_lua and 120 or my_defaults.max_line_len
end

local function markdown(lexer)
   local is_markdown = lexer == 'markdown'
   if not is_markdown then return end

   textadept.editing.strip_trailing_spaces = (not is_markdown) and my_defaults.strip_trailing_spaces
   buffer.tab_width = is_markdown and 4 or my_defaults.tab_width
end

local function luacheck(lexer)
   _M.ta_luacheck = require 'ta-luacheck'
   _M.ta_luacheck[open_or_close_by_lexer(lexer, 'lua')]()
end

local function love(lexer)
   _M.ta_love = require 'ta-love'
   _M.ta_love[open_or_close_by_lexer('lua')]()
end

local function unity(lexer)
   if WIN32 and lexer == 'csharp' then
   if not WIN32 then return end

      _M.ta_unity = require 'ta-unity'
   end
end

local function terra(lexer)
   if lexer == 'terra' then
   if not lexer then return end

      _M.terra = require 'terra'
   end
end

textadept.file_types.extensions.t = "terra"

nautilus()

events.connect(events.LEXER_LOADED, function(lexer)
   andre_la()

   csharp(lexer)
   nelua(lexer)
   lua(lexer)
   markdown(lexer)
   luacheck(lexer)
   love(lexer)
   unity(lexer)
   terra(lexer)
end)
