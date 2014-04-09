" Location of the ag utility
if !exists("g:agprg")
  if executable('ag')
    let s:ag_default_options = " -s --nocolor --nogroup --column"
    let g:agprg = "ag"
  elseif executable('ack')
    let s:ag_default_options = " -s -H --nocolor --nogroup --column"
    let g:agprg = "ag-grep"
  elseif executable('ack-grep')
    let s:ag_default_options = " -s -H --nocolor --nogroup --column"
    let g:agprg = "ag-grep"
  else
    finish
  endif
  let g:agprg .= s:ag_default_options
endif

let s:agprg_version = str2nr(matchstr(system(g:agprg . " --version"),  '[0-9.]\+'))

if !exists("g:ag_apply_qmappings")
  let g:ag_apply_qmappings = !exists("g:ag_qhandler")
endif

if !exists("g:ag_apply_lmappings")
  let g:ag_apply_lmappings = !exists("g:ag_lhandler")
endif

if !exists("g:ag_qhandler")
  let g:ag_qhandler = "botright copen"
endif

if !exists("g:ag_lhandler")
  let g:ag_lhandler = "botright lopen"
endif

if !exists("g:aghighlight")
  let g:aghighlight = 0
end

function! s:Ag(cmd, args)
  redraw
  echo "Searching ..."

  " If no pattern is provided, search for the word under the cursor
  if empty(a:args)
    let l:grepargs = expand("<cword>")
  else
    let l:grepargs = a:args . join(a:000, ' ')
  end

  " Format, used to manage column jump
  if a:cmd =~# '-g$'
    let g:agformat="%f"
  else
    let g:agformat="%f:%l:%c:%m,%f:%l:%m"
  end

  let grepprg_bak=&grepprg
  let grepformat_bak=&grepformat
  try
    let l:agprg_run = g:agprg
    if a:cmd =~# '-g$' && s:agprg_version >= 2
      " remove arguments that conflict with -g
      let l:agprg_run = substitute(l:agprg_run, '-H\|--column', '', 'g')
    end
    let &grepprg=l:agprg_run
    let &grepformat=g:agformat
    " NOTE: we escape special chars, but not everything using shellescape to
    "       allow for passing arguments etc
    silent execute a:cmd . " " . escape(l:grepargs, '|#%')
  finally
    let &grepprg=grepprg_bak
    let &grepformat=grepformat_bak
  endtry

  if a:cmd =~# '^l'
    exe g:ag_lhandler
    let l:apply_mappings = g:ag_apply_lmappings
    let l:close_cmd = ':lclose<CR>'
  else
    exe g:ag_qhandler
    let l:apply_mappings = g:ag_apply_qmappings
    let l:close_cmd = ':cclose<CR>'
  endif

  if l:apply_mappings && &ft == "qf"
    if !exists("g:ag_autoclose") || !g:ag_autoclose
      exec "nnoremap <buffer> <silent> q " . l:close_cmd
      exec "nnoremap <buffer> <silent> t <C-W><CR><C-W>T"
      exec "nnoremap <buffer> <silent> T <C-W><CR><C-W>TgT<C-W>j"
      exec "nnoremap <buffer> <silent> o <CR>"
      exec "nnoremap <buffer> <silent> O <CR><C-W><C-W>:ccl<CR>"
      exec "nnoremap <buffer> <silent> go <CR><C-W>j"
      exec "nnoremap <buffer> <silent> h <C-W><CR><C-W>K"
      exec "nnoremap <buffer> <silent> H <C-W><CR><C-W>K<C-W>b"
      exec "nnoremap <buffer> <silent> v <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t"
      exec "nnoremap <buffer> <silent> gv <C-W><CR><C-W>H<C-W>b<C-W>J"
    else
      exec "nnoremap <buffer> <silent> q " . l:close_cmd
      exec "nnoremap <buffer> <silent> t <C-W><CR><C-W>T" . l:close_cmd
      exec "nnoremap <buffer> <silent> T <C-W><CR><C-W>TgT<C-W>j" . l:close_cmd
      exec "nnoremap <buffer> <silent> o <CR>" . l:close_cmd
      exec "nnoremap <buffer> <silent> O <CR><C-W><C-W>:ccl<CR>" . l:close_cmd
      exec "nnoremap <buffer> <silent> go <CR><C-W>j" . l:close_cmd
      exec "nnoremap <buffer> <silent> h <C-W><CR><C-W>K" . l:close_cmd
      exec "nnoremap <buffer> <silent> H <C-W><CR><C-W>K<C-W>b" . l:close_cmd
      exec "nnoremap <buffer> <silent> v <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t" . l:close_cmd
      exec "nnoremap <buffer> <silent> gv <C-W><CR><C-W>H<C-W>b<C-W>J" . l:close_cmd
    endif

    " If auto preview in on, remap j and k keys
    if exists("g:agpreview")
      exec "nnoremap <buffer> <silent> j j<CR><C-W><C-W>"
      exec "nnoremap <buffer> <silent> k k<CR><C-W><C-W>"
    endif
  endif

  " If highlighting is on, highlight the search keyword.
  if g:aghighlight
    let @/ = substitute(l:grepargs,'["'']','','g')
    set hlsearch
    call feedkeys(":let &hlsearch=1\<CR>", "n")
  end

  redraw!
endfunction

function! s:AgFromSearch(cmd, args)
  let search =  getreg('/')
  " translate vim regular expression to perl regular expression.
  let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
  call s:Ag(a:cmd, '"' .  search .'" '. a:args)
endfunction

function! s:GetDocLocations()
  let dp = ''
  for p in split(&rtp,',')
    let p = p.'/doc/'
    if isdirectory(p)
      let dp = p.'*.txt '.dp
    endif
  endfor
  return dp
endfunction

function! s:AgHelp(cmd,args)
  let args = a:args.' '.s:GetDocLocations()
  call s:Ag(a:cmd,args)
endfunction

function! s:AgWindow(cmd,args)
  let files = tabpagebuflist()
  " remove duplicated filenames (files appearing in more than one window)
  let files = filter(copy(sort(files)),'index(files,v:val,v:key+1)==-1')
  call map(files,"bufname(v:val)")
  " remove unnamed buffers as quickfix (empty strings before shellescape)
  call filter(files, 'v:val != ""')
  " expand to full path (avoid problems with cd/lcd in au QuickFixCmdPre)
  let files = map(files,"shellescape(fnamemodify(v:val, ':p'))")
  let args = a:args.' '.join(files)
  call s:Ag(a:cmd,args)
endfunction

command! -bang -nargs=* -complete=file Ag call s:Ag('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=file AgAdd call s:Ag('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgFromSearch call s:AgFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAg call s:Ag('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAgAdd call s:Ag('lgrepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgFile call s:Ag('grep<bang> -g', <q-args>)
command! -bang -nargs=* -complete=help AgHelp call s:AgHelp('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=help LAgHelp call s:AgHelp('lgrep<bang>',<q-args>)
command! -bang -nargs=* -complete=help AgWindow call s:AgWindow('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=help LAgWindow call s:AgWindow('lgrep<bang>',<q-args>)
