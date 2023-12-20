"=============================================================================
" FILE: myutil.vim
" AUTHOR:  aikawa
" License: MIT license
"=============================================================================

if exists('g:loaded_myutil')
  finish
endif
let g:loaded_myutil = 1

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

call s:set('g:myutil_save_time', 3000 )
call s:set('g:myutil_enable', 1 )

augroup myutil
  autocmd!
  autocmd FileType gitcommit setlocal spell
  autocmd FileType qf call myutil#qf_enhanced()
  autocmd BufWritePre * call myutil#auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  autocmd InsertLeave * call myutil#fcitx2en()
  autocmd TextYankPost,TextChanged,InsertEnter * call myutil#yank_toggle_flag()
augroup END

command!
  \ -nargs=+ -bang
  \ -complete=command
  \ Capture
  \ call myutil#cmd_capture([<f-args>], <bang>0)

command! -nargs=* TERM split | resize20 | term <args>

let &cpo = s:save_cpo
unlet s:save_cpo
