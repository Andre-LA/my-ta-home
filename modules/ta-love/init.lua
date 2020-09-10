local function run_love()
  local working_path = buffer.filename:match("^(.*/).*")
  os.execute('love ' .. working_path)
end

local already_open = false

return {
  open = function()
    if already_open then return end

    -- register Luacheck Menubar -> in Tools -> Run luaCheck
    local tools_menu = textadept.menu.menubar[_L['_Tools']]
    tools_menu[#tools_menu + 1] = {'Run _Love', run_love}

    already_open = true
  end,
  close = function()
    if not already_open then return end
    local tools_menu = textadept.menu.menubar[_L['_Tools']]
    local tools_menu_index = 0

    for i=1, #tools_menu do
      if tools_menu[i][1] == 'Run _Love' then
        tools_menu_index = i
      end
    end

    table.remove(tools_menu, tools_menu_index)

    already_open = false
  end
}

