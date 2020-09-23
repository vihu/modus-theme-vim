if version > 580
  hi clear
  if exists("syntax_on")
    syntax reset
  endif
endif

let g:colors_name='modus-vivendi'

if !exists('g:modus_faint_syntax')
  let g:modus_faint_syntax = 0
endif

lua for k in pairs(package.loaded) do if k:match("^modus%-vivendi") then package.loaded[k] = nil end end
lua require('modus-vivendi')
