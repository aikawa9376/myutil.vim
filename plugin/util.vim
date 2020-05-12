"=============================================================================
" FILE: util.vim
" AUTHOR:  aikawa
" License: MIT license
"=============================================================================

if exists('g:loaded_util')
  finish
endif
let g:loaded_util = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:set(var, default)
  if !exists(a:var)
    if type(a:default)
      execute 'let' a:var '=' string(a:default)
    else
      execute 'let' a:var '=' a:default
    endif
  endif
endfunction

call s:set('g:util_save_time', 3000 )
call s:set('g:util_enable', 1 )

augroup util
  autocmd!
augroup END

command! utilToggle call util#toggle()

set foldtext=util#customfoldtext()

let &cpo = s:save_cpo
unlet s:save_cpo
