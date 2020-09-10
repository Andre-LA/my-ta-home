local M = {}

local unity_snippets = {
   GetComp = "GetComponent<%1>();",
   FindObj = "FindObjectOfType<%1>();",
   FindObjs = "FindObjectsOfType<%1>();",
   GbjFind = 'GameObject.Find("%1");',
   GbjFindWTag = 'GameObject.FindWithTag("%1");',
}

M.tag_file = _USERHOME .. '/modules/ta-unity/tags'
M.api_file = _USERHOME .. '/modules/ta-unity/api'

function M.load_script_reference_filenames(dir)
   local function valid_sr_file(filename)
      return (
         filename ~= '30_search.html' and filename ~= '40_history.html' and filename ~= 'docdata'
         and filename ~= 'uapi.exe' and filename ~= '.' and filename ~= '..'
      )
   end

   local files_list = {}
   local n = 0

   for file_v in lfs.dir(dir) do
      if file_v and valid_sr_file(file_v) then
         n = n + 1
         files_list[n] = file_v
      end
   end

   return files_list
end

function M.generate_tags(sr_files)
   local result_list = {}

   for i=1, #sr_files do
      local sr_file = sr_files[i]

      local prefix = sr_file:match('^(%S+)[%.%-]%w+%.html')
      local last   = sr_file:match('([%.%-]%w+).html$')
      local all    = sr_file:match('^(%S+)%.html')

      --ui.print('[\n')
      --[[
      ui.print(
      '-> sr_file: '.. tostring(sr_file) .. '\n\t '
      .. 'prefix: ' .. tostring(prefix) .. '\n\t '
      .. 'last: '   .. tostring(last) .. '\n\t '
      .. 'all: '    .. tostring(all)
      )
      --]]

      -- 'm' = XPM.CLASS, 'f' = XPM.METHOD, 'F' = XPM.VARIABLE, 't' = XPM.TYPEDEF
      local xpm_result;
      local tag;

      if prefix and last then
         -- this sub() return '-' if property, '.' if method, nil otherwise
         local sr_type = last:sub(1, 1)

         if sr_type == '-' then
            xpm_result = 'F'
         elseif sr_type == '.' then
            xpm_result = 'f'
         end

         --example: 'table.concat' is 'concat	f	class:table'
         tag = last:sub(2) .. '\t'.. xpm_result .. '\t' .. prefix
      else
         xpm_result = 'm'

         --example: 'table' is 'table	m'
         tag = all .. '\t'.. xpm_result .. '\t'
      end

      --ui.print('\t 2:' .. tostring(tag))
      --ui.print(']\n')

      result_list[#result_list + 1] = tag
   end

   table.sort(result_list)

   return result_list
end

function M.generate_api(unity_path, sr_files)
   local result_list = {}

   for i=1, #sr_files do
      local sr_file = sr_files[i]

      local last   = sr_file:match('([%.%-]%w+).html$')
      local all    = sr_file:match('^(%S+)%.html')

      --ui.print('~> sr_file: '.. tostring(sr_file) .. '\n\t '
      --  .. 'last: '   .. tostring(last) .. '\n\t '
      --  .. 'all: '    .. tostring(all) .. '\n'
      --  .. 'ioopen: ' .. (unity_path .. sr_file)
      --)


      local sr_file = io.open(unity_path .. sr_file)
      local sr_file_content = sr_file:read('a')
      sr_file:close()

      local api_symbol_name = (last or all):gsub("([%.%-])", "")
      local api_doc_title = all:gsub("(%-+)", ".")
      local api_doc_description = (
         sr_file_content:match("<h2>Description</h2>%s*<p>(.-)</p>")
         or api_doc_title .. ': failed to load doc description :('
      )

      --ui.print( '~~\n\t'
      --  .. 'api_symbol_name: ' .. tostring(api_symbol_name) .. '\n\t'
      --  .. 'api_doc_title: ' .. tostring(api_doc_title) .. '\n\t'
      --  .. 'api_doc_description: ' .. tostring(api_doc_description) .. '\n\t'
      --)

      local api = api_symbol_name .. ' ' .. api_doc_title .. '\\n' .. api_doc_description
      table.insert(result_list, api)
   end

   table.sort(result_list)

   return result_list
end

if not textadept.editing.api_files.csharp then
   textadept.editing.api_files.csharp = {_USERHOME .. '/modules/ta-unity/api'}
end

for k, v in pairs(unity_snippets) do
   snippets.csharp[k] = v
end

if not textadept.editing.autocompleters.csharp then
   textadept.editing.autocompleters.csharp = function ()
      local list = {}

      local line, pos = buffer:get_cur_line()

      --[[
      -- ANDRÉ DO FUTURO, É O SEGUINTE:
      -- meu_transform.Translate()
      -- digamos que nossa linha no buffer seja
      -- meu_transform.Trans|
      -- Queremos, claro, que venha a sugestão Translate

      -- Agora, os problemas são

      -- Não conseguimos, apenas com a informação vinda do .html da referência,
      -- inferir se um símbolo é uma função estática ou método
      -- logo, não temos como saber que o .Translate() é um método

      -- logo, a sugestão de .Translate só poderá vir junto
      -- com toda uma galera que não pertence a Transform (por exemplo, transparentSwapchain, de PlayerSettings.WSA)

      -- possíveis soluções inteligentes (ainda usando Translate):

      -- primeiro, os fatos:
      -- Translate é um método nas classes Transform, Matrix4x4, e Plane
      -- Não existe Translate como 'Translate--->m'

      -- logo, o 1º pressuposto definitivo e simples:
      -- "TRANSLATE" NÃO DEVE ENTRAR NA LISTA DE SUGESTÕES SE TAG_PREFIX = NIL

      -- isso já daria um filtro, mas ainda Podemos melhorar:

      -- Embora falho, podemos analisar, usando autocompletador de Lua do TextAdept
      -- se o symbol é um dos tag_prefix

      -- isso seria uma solução para funções estáticas, mas ainda:

      -- analisando symbol, procuramos por local decl_type, decl_assign = string.match("(%S+)%s+symbol%s*=?%s*(%S*);")
      -- se decl_type é "var" ou um dos tag_prefix, então o tipo declarado é válido
      -- e tag_name poderá entrar na lista de sugestões

      -- caso decl_type seja var e se decl_assign contém '<tag_type>(.*)',
      -- então a sugestão também é válida

      -- voltando ao exemplos, usando o pattern da linha 119, consideremos 3 casos,
      -- usando
      -- local t = caso; local a, b = string.match(t, "(%S+)%s+meu_tr%s*=?%s*(%S*);"); ui.print('a:[' .. tostring(a) .. ']', 'b:[' .. tostring(b) .. ']')

      --[[ caso 1
      t = Transform meu_tr; ~> a:[Transform]	b:[]
      --]]
      --[[ caso 2
      t = Transform meu_tr = outroLugar.transform; ~> a:[Transform]	b:[outroLugar.transform]
      ]]
      --[[ caso 3
      t = var meu_tr = outroLugar.tranform ~> a:[var]	b:[outroLugar.transform]
      ]]

      -- repetindo os casos 2 e 3 usando match das linhas 123
      -- usando
      -- local t = caso_resultado_b; local a, b = string.match(t, ".*<(Transform)>%(.*%)$"); ui.print('a:[' .. tostring(a) .. ']', 'b:[' .. tostring(b) .. ']')

      -- caso 2 e 3: a:[nil]	b:[nil]

      --[[ caso 4
      var meu_tr = outroLugar.GetComponent<Transform>();
      ]]
      -- usando primeiro teste ~> a:[var]	b:[outroLugar.GetComponent<Transform>()]
      -- usando segundo teste ~> a:[Transform]	b:[nil]

      -- achos que esses padrões Lua de texto estão ótimos!
      -- enfim, no final:

      -- se symbol and not tag_prefix -> não pode incluir tag_name na lista
      -- senão então
      --   se tag_prefix == symbol -> pode incluir -- resolve estáticos, embora inclua métodos como estáticos erroneamente
      --     senão então
      --       local decl_type, decl_assign = procura declaracao de tag_name usando o 1º padrão testado, a busca é de baixo (a partir da linha do buffer) pra cima
      --       se decl_type == tag_prefix -> pode incluir
      --       senão e se decl_type ~= 'var' -> não pode incluir
      --       senão então
      --         se o match do decl_assign usando o 2º padrão testado retorna tag_prefix -> pode incluir

      -- última observação sobre esse algoritimo
      -- toda as vezes que estou com tag_prefix, tem que considerar como
      -- tag_prefix ou tag_prefix_last_symbol,
      -- visto que, usando "PlayerSettings.WSA"
      -- tag_prefix = PlayerSettings.WSA, tag_prefix_last_symbol = WSA
      -- boa sorte ;)
      --]]

      local part_prefix, part = line:sub(1, pos):match('([%w+])([%w_]+)')
      local line_to_complete = line:match("%s*(%S+)%s*"):lower():gsub("(%.)", "%%.")

      --ui.print("\nline str: " .. line:sub(1, pos))
      --ui.print("line: " .. line .. " | pos: " .. pos)
      --ui.print("line to complete: " .. tostring(line_to_complete))

      local XPM = textadept.editing.XPM_IMAGES
      local xpms = {
         m = XPM.CLASS,
         f = XPM.METHOD,
         F = XPM.VARIABLE,
         t = XPM.TYPEDEF
      }

      local sep = string.char(buffer.auto_c_type_separator)

      if lfs.attributes(M.tag_file) then
         for tag_line in io.lines(M.tag_file) do
            local tag_name, tag_xpm_char = tag_line:match('(%S*)\t(%a)')
            local tag_prefix = tag_line:match('%S*\t%a\t(%S*)')

            local tag_all = (tag_prefix or "") .. (tag_prefix and '.' or '') .. tag_name
            tag_all = tag_all:lower()

            local tag_found = tag_all:match('^(' .. line_to_complete .. ')')

            if tag_found then
               --ui.print("tag_all: " .. tag_all)
               --ui.print("tag_found: " .. tostring(tag_found))

               if not list[tag_name] then
                  list[#list + 1] = string.format('%s%s%d', tag_name, sep, xpms[tag_xpm_char])
                  list[tag_name] = true
               end
            end
         end
      end


      local symbol = line:sub(1, pos):match("%.?([%w_]+)$")
      local pos_caret = symbol and symbol:len() or 0

      return pos_caret, list
   end
end

local tools = textadept.menu.menubar[_L['_Tools']]

tools[#tools+1] = {
   title = 'TA-_Unity',
   {
      "Generate Tags from Unity's ScriptReference",
      function()
         -- load script reference filenames
         local unity_path = ui.dialogs.fileselect(
            {title = "Select Unity's script reference folder", select_only_directories = true}
         )

         if not unity_path then
            ui.dialogs.msgbox({
               title = "Not valid Unity path",
               text = "Fail in opening Unity script refernce folder",
               icon = "gtk-dialog-error"
            })
            return
         end

         local sr_files_list = M.load_script_reference_filenames(unity_path)

         -- generate tags as array and convert to string using '\n' as separator
         local tags_str = table.concat(M.generate_tags(sr_files_list), '\n')
         local api_str  = table.concat(M.generate_api(unity_path  .. '\\', sr_files_list), '\n')

         -- write tags
         io.open(M.tag_file, 'w'):write(tags_str):close()

         -- write api
         io.open(M.api_file, 'w'):write(api_str):close()
      end
   }
}


return M
