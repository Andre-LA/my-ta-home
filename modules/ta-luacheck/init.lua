local function run_luacheck()
  local working_path = buffer.filename:match("^(.*/).*")

  local options = '--no-color --max-line-length ' .. tostring(buffer.edge_column) .. ' '
  -- spawn luacheck process

  local lc_proc, lc_proc_err =
    os.spawn('luacheck ' .. options .. buffer.filename, working_path)

  if not lc_proc then
    error(lc_proc_err)
  end

  local clean_buffer = false
  repeat
    -- read (line) message printed by luacheck
    local lc_result, _ = lc_proc:read()


    if lc_result ~= nil then
      if not clean_buffer then
        -- create a new "[Message Buffer]" buffer if it is already not exists
        ui.print ' '
        -- clear the "[Message Buffer]"
        buffer.clear_all(_L['[Message Buffer]'])
        clean_buffer = true
      end
      -- print message if exists
      ui.print(lc_result)
    end

  until not lc_result

  lc_proc:wait()
end

local already_open = false

return {
  open = function()
    if already_open then return end

    -- register Luacheck Menubar -> in Tools -> Run luaCheck
    local tools_menu = textadept.menu.menubar[_L['_Tools']]
    table.insert(tools_menu, {'Run _Luacheck', run_luacheck})

    already_open = true
  end,
  close = function()
    if not already_open then return end
    local tools_menu = textadept.menu.menubar[_L['_Tools']]
    local tools_menu_index = 0

    for i=1, #tools_menu do
      if tools_menu[i][1] == 'Run _Luacheck' then
        tools_menu_index = i
      end
    end

    table.remove(tools_menu, tools_menu_index)

    already_open = false
  end
}
