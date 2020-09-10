local csharp_snippets = require 'csharp.snippets'

if type(snippets) == 'table' then
   snippets.csharp = csharp_snippets
end

local function set_style_settings()
   buffer.tab_width = 4
   buffer.use_tabs = false
end

events.connect(events.LEXER_LOADED, function(lexer)
   if lexer == 'csharp' then
      set_style_settings()
   end
end)
