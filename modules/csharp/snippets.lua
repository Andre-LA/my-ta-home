local _CLASS_MEMBERS_ACCESS_MODIFIERS = '{,public ,private ,protected ,internal ,protected internal ,private protected }'
local _CLASS_ACCESS_MODIFIERS = '{,public ,internal }'
local _STRUCT_FIELD_ACCESS_MODIFIERS = '{,public ,private ,internal }' -- TODO: I don't know if it''s just these 3 access modifiers
local _CASE = 'case %1(match):\n\t'
local _DEFAULT = 'default %1(match):\n\t'

local function _scope(n, inside_scope)
  return '\n{\n\t' .. n .. (inside_scope ~= nil and inside_scope or '') .. '\n}'
end

return {
  var = 'var %1(varName) = %2(expr)',
  func = '%1' .. _CLASS_MEMBERS_ACCESS_MODIFIERS .. '%2(rettype) %3(FunctionName) (%4(args))' .. _scope('%0'),
  class = '%1' .. _CLASS_ACCESS_MODIFIERS .. 'class %2(ClassName) %3(: InheritsFromThis)' .. _scope('%0'),
  ['if'] = 'if (%1(condition))' .. _scope('%0'),
  eif = 'else if (%1(condition))' .. _scope('%0'),
  ['else'] = 'else' .. _scope('%0'),
  sw = 'switch (%1(condition))' .. _scope('%0'),
  case = _CASE,
  casebr = _CASE ..  '%0\n\tbreak;',
  caseret = _CASE ..  'return %0;',
  default = _DEFAULT,
  defaultbr = _DEFAULT .. '%0\n\tbreak;',
  defaultret = _DEFAULT .. 'return %0;',
  ['do'] = 'do' .. _scope('%0') .. ' while (%1(condition))',
  ['for'] = 'for (%1(initializer); %2(condition); %3(iterator))' .. _scope('%0'),
  fori = 'for (%1(int) %2(i) = %3(0); %2 %4(<) %5(count); %2%6(++))' .. _scope('%0'),
  fore = 'foreach (%1(type) %2(element) in %3(enumerable))' .. _scope('%0'),
  foreach = 'foreach (%1(type) %2(element) in %3(enumerable))' .. _scope('%0'),
  ['while'] = 'while (%1(condition))' .. _scope('%0'),
  namespace = 'namespace %1(namespaceName)' .. _scope('%0'),
  struct = 'struct %1(structName) ' .. _scope('%2', _STRUCT_FIELD_ACCESS_MODIFIERS .. '%3(fieldType) %4(fieldName);\n\t%0'),
  using = 'using %0;',
  interface = 'interface I%1' .. _scope('%0'),
  pif = '#if %1\n%0\n#endif',
  pregion = '#region %1\n%0\n#endregion',
  enum = --[[_ENUM_ACESS_MODIFIERS .. ]] 'enum %1 ' .. _scope('%0'),
}
