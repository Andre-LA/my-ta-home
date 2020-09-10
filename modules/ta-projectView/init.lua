local M = {}

M.projectDir = lfs.currentdir()
M.filter = {
  extensions = {},
  folders = {}
}

-- show buffer w
function M.showFileSearch()
  local tempFolders = {}

  -- copy folders to new table
  for i, folder in ipairs(M.filter.folders) do
    table.insert(
      tempFolders,
      M.projectDir .. '\\' .. folder
    )
  end

  -- open dialog
  io.quick_open(
    M.projectDir,
    {
      extensions = M.filter.extensions,
      folders = tempFolders
    }
  )
end

function M.excludeExtensions()
  local exclExt = ''
  local newExt = {}
  local status

  -- excluded extensions as string
  for _, ext in ipairs(M.filter.extensions) do
    exclExt =
      exclExt ..
      '\r\n' ..
      ext
  end

  -- show dialog
  status, exclExt = ui.dialogs.textbox
  {
    title = 'Exclude extensions',
    informative_text = 'separate by line',
    text = exclExt,
    editable = true
  }

  -- recreate table from string
  for substr in exclExt:gmatch('[^\r\n]+') do
    table.insert(newExt, substr)
  end

  if status ~= _L['_OK'] then
    M.filter.extensions = newExt
  end
end

function M.excludeFolders()
  local exclFolders = ''
  local newFolders = {}
  local status

  -- put excluded folders as string
  for i, folder in ipairs(M.filter.folders) do
    exclFolders =
      exclFolders ..
      '\r\n' ..
      folder
  end

  -- show dialog
  status, exclFolders = ui.dialogs.textbox
  {
    title = 'Exclude folders',
    informative_text = 'separate by line',
    text = exclFolders,
    editable = true
  }

  -- recreate table from string
  for substr in exclFolders:gmatch('[^\r\n]+') do
    table.insert(newFolders, substr)
  end

  if status ~= _L['_OK'] then
    M.filter.folders = newFolders
  end
end

-- add project menu
local projectMenu = {
  title = '_Project',
  {
    'Search File',
    M.showFileSearch
  },
  {
    'Set Project _Directory', -- set project directory
    function()
      M.projectDir = ui.dialogs.fileselect({
        title = '',
        select_only_directories = true,
        with_directory = M.projectDir
      })
    end
  }
}

local exlcudeMenu = {
  title = '_Exclude',
  {
    '_Directories',
    M.excludeFolders
  },
  {
    '_Extensions',
    M.excludeExtensions
  }
}

-- add exclude submenu to projectMenu
projectMenu[#projectMenu + 1] = exlcudeMenu

-- add project menu to textadept top-level menubar
textadept.menu.menubar[#textadept.menu.menubar + 1] = projectMenu

return M
