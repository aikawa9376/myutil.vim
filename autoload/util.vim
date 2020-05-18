"=============================================================================
" FILE: myutil.vim
" AUTHOR: aikawa
" License: MIT license
"=============================================================================

" fold ---------------------
function! myutil#custom_fold_text() abort
  "get first non-blank line
  let fs = v:foldstart
  while getline(fs) =~# '^\s*$' | let fs = nextnonblank(fs + 1)
  endwhile
  if fs > v:foldend
    let line = getline(v:foldstart)
  else
    let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
  endif

  let foldsymbol='+'
  let repeatsymbol=''
  let prefix = foldsymbol . ' '

  let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
  let foldSize = 1 + v:foldend - v:foldstart
  let foldSizeStr = ' ' . foldSize . ' lines '
  let foldLevelStr = repeat('+--', v:foldlevel)
  let lineCount = line('$')
  let foldPercentage = printf('[%.1f', (foldSize*1.0)/lineCount*100) . '%] '
  let expansionString = repeat(repeatsymbol, w - strwidth(prefix.foldSizeStr.line.foldLevelStr.foldPercentage))
  return prefix . line . expansionString . foldSizeStr . foldPercentage . foldLevelStr
endfunction

" QuickFix ---------------------
function! myutil#qf_enhanced()
  nnoremap <buffer> p  <CR>zz<C-w>p
  nnoremap <silent> <buffer> dd :call <SID>del_entry()<CR>
  nnoremap <silent> <buffer> x :call <SID>del_entry()<CR>
  vnoremap <silent> <buffer> d :call <SID>del_entry()<CR>
  vnoremap <silent> <buffer> x :call <SID>del_entry()<CR>
  nnoremap <silent> <buffer> u :<C-u>call <SID>undo_entry()<CR>
endfunction

function! s:undo_entry()
  let history = get(w:, 'qf_history', [])
  if !empty(history)
    call setqflist(remove(history, -1), 'r')
  endif
endfunction

function! s:del_entry() range
  let qf = getqflist()
  let history = get(w:, 'qf_history', [])
  call add(history, copy(qf))
  let w:qf_history = history
  unlet! qf[a:firstline - 1 : a:lastline - 1]
  call setqflist(qf, 'r')
  execute a:firstline
endfunction

" auto mkdir ---------------------
function! myutil#auto_mkdir(dir, force)
  if !isdirectory(a:dir) && (a:force ||
        \    input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction

" local setting ---------------------
function! myutil#vimrc_local(loc)
  let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
  for i in reverse(filter(files, 'filereadable(v:val)'))
    source `=i`
  endfor
endfunction

" vim command capture ---------------------
function! s:capture(cmd)
  redir => result
  silent execute a:cmd
  redir END
  return result
endfunction

function! myutil#cmd_capture(args, banged)
  new
  silent put =s:capture(join(a:args))
  1,2delete _
endfunction

function! myutil#set_default(var, val, ...) abort
  if !exists(a:var) || type({a:var}) != type(a:val)
    let alternate_var = get(a:000, 0, '')

    let {a:var} = exists(alternate_var) ?
          \ {alternate_var} : a:val
  endif
endfunction

" toggle function ---------------------
function! myutil#toggle_syntax() abort
  if exists('g:syntax_on')
    syntax off
    redraw
    echo 'syntax off'
  else
    syntax on
    redraw
    echo 'syntax on'
  endif
endfunction
function! myutil#toggle_relativenumber() abort
  if &relativenumber == 1
     setlocal norelativenumber
  else
     setlocal relativenumber
  endif
endfunction

" insert leave ime off ---------------------
let s:input_toggle = 1
function! myutil#fcitx2en()
  let s:input_status = system('fcitx-remote')
  if s:input_status == 2
    let s:input_toggle = 1
    let l:a = system('fcitx-remote -c')
  endif
endfunction

" search highlight toggle ---------------------
nmap <Plug>(my-hltoggle) mz<Esc>:%s/\(<C-r>=expand("<cword>")<Cr>\)//gn<CR>`z
function! myutil#hl_text_toggle()
  if v:hlsearch != 0
    call feedkeys(":noh\<CR>")
  else
    call feedkeys("\<Plug>(my-hltoggle)")
  endif
endfunction

" delete line enhance ---------------------
function! myutil#remove_line_brank(count)
  for i in range(1, v:count1)
    if getline('.') ==# ''
      .delete _
    else
      .delete
    endif
  endfor
  call repeat#set('dd', v:count1)
endfunction

function! myutil#remove_line_brank_all(count)
  for i in range(1, v:count1)
    if getline('.') ==# ''
      .delete _
    else
      .delete
    endif
  endfor
  while getline('.') ==# ''
      .delete _
  endwhile
  call repeat#set('dD', v:count1)
endfunction

" top and bottom yank ---------------------
function! s:yank_after_indent()
  normal! gV=gV^
endfunction
function! myutil#yank_line(flag)
  if a:flag ==# 'j'
    let line = line('.')
    let repeat = ']p'
  else
    let line = line('.') - 1
    let repeat = '[p'
  endif
  call append(line, '')
  execute 'normal! ' . a:flag . 'p'
  call s:yank_after_indent()
  call repeat#set(repeat, '')
endfunction

" yank toggle ---------------------
function! myutil#yank_text_toggle()
  if b:yank_toggle_flag != 0
    execute 'normal `['
    let b:yank_toggle_flag = 0
  else
    execute 'normal `]'
    let b:yank_toggle_flag = 1
  endif
endfunction
function! myutil#yank_toggle_flag() abort
  let b:yank_toggle_flag = 1
endfunction

" auto indent start insert
function! myutil#indent_with_i()
    if len(getline('.')) == 0
        return 'cc'
    else
        return 'i'
    endif
endfunction

" gJで空白を削除する
function! myutil#join_space_less()
    execute 'normal gj'
    " Character under cursor is whitespace?
    if matchstr(getline('.'), '\%' . col('.') . 'c.') =~? '\s'
        " When remove it!
        execute 'normal dw'
    endif
    call repeat#set('gJ', v:count1)
endfunction

" vimrcをスペースドットで更新
function myutil#reload_vimrc() abort
  execute printf('source %s', $MYVIMRC)
  if has('gui_running')
    execute printf('source %s', $MYGVIMRC)
  endif
  redraw
  echo printf('.vimrc/.gvimrc has reloaded (%s).', strftime('%c'))
endfunction

" macro visual selection ---------------------
function! myutil#execute_macro_visual_range()
  echo '@'.getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

" ex command line enhance ---------------------
function! myutil#ctrl_u() abort "{{{ rsi ctrl-u, ctrl-w
  if getcmdpos() > 1
    let @- = getcmdline()[:getcmdpos()-2]
  endif
  return "\<C-U>"
endfunction

function! myutil#ctrl_w_before() abort
  let s:cmdline = getcmdpos() > 1 ? getcmdline() : ''
  return "\<C-W>"
endfunction

function! myutil#ctrl_w_after() abort
  if strlen(s:cmdline) > 0
    let @- = s:cmdline[(getcmdpos()-1) : (getcmdpos()-2)+(strlen(s:cmdline)-strlen(getcmdline()))]
  endif
  return ''
endfunction

" help override ---------------------
function! myutil#help_override() abort
  let vtext = s:get_visual_selection()
  let word = expand('<cword>')
  if vtext !=# ''
    let word = vtext
  endif
  try
    execute 'silent help ' . word
  catch
    echo word . ' is no help text'
  endtry
endfunction

" search google ---------------------
function! myutil#google_search() abort
  let vtext = s:get_visual_selection()
  let word = expand('<cword>')
  if vtext !=# ''
    let word = vtext
  endif
  execute 'silent !google-chrome-stable ' .
   \ '"http://www.google.co.jp/search?num=100&q=' . word . '" 2> /dev/null &'
endfunction
function! myutil#google_open() abort
  let vtext = s:get_visual_selection()
  if vtext =~ "^http"
    let url = vtext
  else
    let url = "https://github.com/" . vtext
  endif
  execute 'silent !google-chrome-stable ' .
   \ '"' . url . '" 2> /dev/null &'
endfunction
function! s:get_visual_selection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection ==? 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction
