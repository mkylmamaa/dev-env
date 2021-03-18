" pathogen plugin
let g:pathogen_disabled = ['clang_complete']
call add(g:pathogen_disabled, 'vim-badplugin')
execute pathogen#infect()
Helptags

" syntastic settings
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"nnoremap <silent> ` :Errors<CR>

"let g:syntastic_cpp_config_file = '.clang_complete'

"let g:syntastic_cpp_check_header=1
"let g:syntastic_always_populate_loc_list=1
"let g:syntastic_auto_loc_list=1
"let g:syntastic_check_on_open=0
"let g:syntastic_check_on_write=0
"let g:syntastic_check_on_wq=0
"let g:syntastic_enable_signs=1

" clang_complete settings

"let g:clang_use_library = 1
"let g:clang_periodic_quickfix = 0
"let g:clang_close_preview = 1
"let g:clang_complete_auto = 0
"let g:clang_complete_copen = 1
"let g:clang_complete_macros = 1
"let g:clang_complete_patterns = 0
"let g:clang_memory_percent=70
"let g:clang_auto_select=1
"let g:clang_snippets=0
""let g:clang_snippets_engine = 'ultisnips'
""let g:clang_snippets_engine='clang_complete'
"
"let g:clang_exec = '/usr/local/opt/llvm/bin/clang'
"let g:clang_library_path = '/usr/local/opt/llvm/lib/libclang.dylib'
    
" NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Ctrl-P
let g:ctrlp_clear_cache_on_exit = 1
let g:ctrlp_use_caching = 0
"let g:ctrlp_custom_ignore = {
"\ 'file': '\v(\.c|\.cpp|\.h|.hpp|\.m|\.mm|\.inl|\.txt|\.sh)@<!$'
"\ }
let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
      \ --ignore .git
      \ --ignore .svn
      \ --ignore .hg
      \ --ignore .DS_Store
      \ -g ""'
let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' } 
let g:ctrlp_by_filename = 1

" Use ag instead of default grep
" set grepprg=ag\ --nogroup\ --nocolor
set grepprg=ag\ --vimgrep\ $*
set grepformat=%f:%l:%c:%m

":set background=dark
"colorscheme darkblue
"colorscheme smyck
colorscheme wikipedia
":set term=xterm-256color
:set term=screen-256color
:set t_Co=256
:set t_ut=

" general settings
:syntax on
:set wrap
:set nocompatible
:set modelines=0
:set gdefault
:set incsearch
:set showmatch
:set hlsearch
:set nobackup
:set nowritebackup
:set noswapfile
:set tabstop=4
:set shiftwidth=4
:set softtabstop=4
:set expandtab
:set number
"hi LineNr ctermfg=4
filetype indent on
filetype plugin on
:set autoread
:set guioptions-=L
:set guioptions-=T
:set guioptions-=r
:set hidden
:set laststatus=2
:set wildchar=<Tab> wildmenu wildmode=full
":set wildcharm=<C-Z>
"nnoremap <F10> :b <C-Z>
:set updatetime=1000
:set backspace=2
:set mouse-=a
:set clipboard=unnamed
:set nofixendofline

if has("gui_running")
	:set fu
endif

" Don't allow editing of read only files
function! ReadOnlyNoEdit()
  if &readonly == 1
    set nomodifiable
  else
    set modifiable
  endif
endfunction

" Search for current word and replace with given text for files in arglist.
function! Replace(bang, wholeword, replace)
  let flag = 'ge'
  if !a:bang
    let flag .= 'c'
  endif
  let search = escape(expand('<cword>'), '/\.*$^~[')
  execute 'silent! arg `ag --vimgrep ' . search . ' \| sed ''s/:.*//''`'
  if a:wholeword
	  let search = '\<' . search . '\>'
  endif
  let replace = escape(a:replace, '/\&~')
  execute 'silent! argdo %s/' . search . '/' . replace . '/' . flag
endfunction
"command! -nargs=1 -bang Replace :call Replace(<bang>0, <q-args>)

" Check-out current file
function! P4Checkout()
  execute 'silent! !p4 edit ' . "%"
endfunction

" Build project
function! BuildProject()
	if exists("g:build_proc")
		echo "Stopping build..."
		call g:build_proc.kill()
		call g:build_proc.waitpid()
		call g:build_output.close()
		unlet g:build_proc
	else
		let statements = [{
			\ 'cwd':'$DEVROOT',
			\ 'statement':'./build_all.sh OSX',
			\ 'condition':'always',
			\ }]
		let g:build_output = vimproc#fopen("build_output.tmp", "wt")
		let g:build_proc = vimproc#pgroup_open(statements)
	endif
endfunction

function! DestroyBuildWindow()
	let s:winnr = bufwinnr("BuildOutput")
	let s:bufnr = bufnr("BuildOutput")
	if s:winnr != -1
		execute s:winnr . 'wincmd w'
		execute 'lclose'
		execute s:winnr . 'wincmd q'
	endif
	if s:bufnr != -1
		execute "bdelete " . s:bufnr
	endif
endfunction

function! ProcessBuildTimer()
	if exists("g:build_proc")
		if !g:build_proc.stdout.eof
			call g:build_output.write(g:build_proc.stdout.read())
		endif
		if !g:build_proc.stderr.eof
			call g:build_output.write(g:build_proc.stderr.read())
		endif
		if g:build_proc.stdout.eof && g:build_proc.stderr.eof
			echo "Build finished"
			call DestroyBuildWindow()
			execute 'silent! rightbelow vertical new BuildOutput'
			"execute 'silent! setl buftype=nofile bufhidden=wipe'
			execute 'silent! setl buftype=nofile'
			execute 'silent! read build_output.tmp'
			execute 'silent! !rm build_output.tmp'
			execute 'silent! highlight build_failed ctermbg=darkred guibg=darkred'
			execute 'silent! highlight build_succeeded ctermbg=darkgreen guibg=darkgreen'
			execute 'silent! highlight errors ctermbg=darkred guibg=darkred'
			execute 'silent! call matchadd("build_failed", ".*BUILD FAILED.*")'
			execute 'silent! call matchadd("build_succeeded", ".*BUILD SUCCEEDED.*")'
			execute 'silent! call matchadd("errors", "error")'
			"execute 'silent! g/error:/laddexpr expand("%") . ":" . line(".") . ":" . getline(".")'
			execute 'silent! g/error:/laddexpr getline(".")'
			execute 'silent! lopen'
			call g:build_proc.kill()
			call g:build_proc.waitpid()
			call g:build_output.close()
			unlet g:build_proc
			unlet g:build_output
		else
			echo "Build in progress..."
		endif
	endif
endfunction

" auto commands
autocmd BufRead * call ReadOnlyNoEdit()
autocmd InsertEnter * set cursorline | hi CursorLine cterm=standout
autocmd InsertLeave * set nocul
" autocmd InsertEnter * if &readonly | call P4Checkout() | endif
autocmd CompleteDone * pclose
"autocmd CursorHold * call feedkeys("g\<ESC>", 'n') | call ProcessBuildTimer()
"autocmd CursorHoldI * call feedkeys("\<C-g>\<ESC>", 'n') | call ProcessBuildTimer()
" disable automatic commenting by the filetype plugin
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" keybinds
map <C-n> :NERDTreeToggle<CR>
"map <C-c> :SyntasticCheck<CR>
map <silent> <C-e> :call P4Checkout()<CR><C-L>
"map <F2> :let filename=expand("%") <bar> :rightbelow vertical new <bar> setl buftype=nofile bufhidden=wipe nobuflisted <bar> :execute 'read !p4 diff '.filename<CR>
map <C-h> :A<CR>
"map <silent> <F5> :call BuildProject()<CR>
"map <F5> :rightbelow vertical new <bar> setl buftype=nofile bufhidden=wipe nobuflisted <bar> :execute "read !cd $DEVROOT && ./build_all.sh OSX"<CR>
"map <S-F5> :let filename=expand("%") <bar> :rightbelow vertical new <bar> setl buftype=nofile bufhidden=wipe nobuflisted <bar> :execute "read !./run OSX Workbench"<CR>
"map <F7> :let @z = join(readfile(".clang_complete"), " ") <bar> :execute "!gcc --analyze ".@z." '%'"<CR>
"map <S-F7> :let filename=expand("%") <bar> :rightbelow vertical new <bar> setl buftype=nofile bufhidden=wipe nobuflisted <bar> :let @z = join(readfile(".clang_complete"), " ") <bar> :silent execute "read !gcc --analyze ".@z." ".filename<CR>

"map <F4> :execute "lvimgrep /" . expand("<cword>") . "/j **" <Bar> lw<CR>
command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
nnoremap <Leader><F3> :Ag<SPACE>
map <F3> :grep! "\b<C-R><C-W>\b"<CR>:cw<CR> 

nnoremap <F4> :call Replace(0, 0, input('Replace '.expand('<cword>').' with: '))<CR>
nnoremap !<F4> :call Replace(1, 0, input('Replace '.expand('<cword>').' with: '))<CR>
nnoremap <Leader><F4> :call Replace(0, 1, input('Replace '.expand('<cword>').' with: '))<CR>
nnoremap <Leader>!<F4> :call Replace(1, 1, input('Replace '.expand('<cword>').' with: '))<CR>

nnoremap <silent> <Leader>p :YRShow<CR>

nnoremap <F10> :BufExplorer<CR>

nnoremap <leader><space> :noh<CR>
nnoremap <tab> %
vnoremap <tab> %

nnoremap / /\v
vnoremap / /\v

nnoremap j gj
nnoremap k gk

nnoremap <F10> :cn<CR>
nnoremap <S-F10> :cN<CR>

" YankRing
let g:yankring_replace_n_pkey = '<Leader>['
let g:yankring_replace_n_nkey = '<Leader>]'
