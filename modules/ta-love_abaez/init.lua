--- default initializer
-- @author Alejandro Baez <alejan.baez@gmail.com>
-- @copyright 2015
-- @license MIT (see LICENSE)
-- @module init

-- run love2d project
textadept.run.build_commands["main.lua"] = "love ."
textadept.editing.comment_string.love = '--'

if type(snippets) == 'table' then
  snippets.love = snippets.lua
end

events.connect(events.LEXER_LOADED, function (lang)
  if lang ~= 'love' then return end

  buffer.tab_width = 2
  buffer.use_tabs = false
  buffer.edge_column = 79
end)

keys.love = {
  ['can'] = function()
    io.open_file(ui.dialogs.filesave{
      with_directory = (buffer.filename or ''):match('^.+[//]')
    })
    buffer:document_start()
    for line in io.open(_USERHOME .. "/modules/love/template.lua"):lines() do
      buffer:add_text(line .. "\n")
    end
  end
}

return {}
