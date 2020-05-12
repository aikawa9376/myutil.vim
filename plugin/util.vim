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
  autocmd FileType gitcommit setlocal spell
  autocmd FileType qf call util#qf_enhanced()
  autocmd BufWritePre * call util#auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  autocmd BufNewFile,BufReadPost * call util#vimrc_local(expand('<afile>:p:h'))
  autocmd InsertLeave * call util#fcitx2en()
  autocmd TextYankPost,TextChanged,InsertEnter * call util#yank_toggle_flag()
augroup END

command!
  \ -nargs=+ -bang
  \ -complete=command
  \ Capture
  \ call util#cmd_capture([<f-args>], <bang>0)

set foldtext=util#custom_fold_text()

let &cpo = s:save_cpo
unlet s:save_cpo
