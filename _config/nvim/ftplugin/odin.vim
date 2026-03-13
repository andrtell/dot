if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

if &filetype != 'odin'
    finish
endif

setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4

setlocal suffixesadd=.odin
setlocal commentstring=//\ %s
setlocal comments=s1:/*,mb:*,ex:*/,://
