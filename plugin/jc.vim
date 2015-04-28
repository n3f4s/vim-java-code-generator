
function! s:GenerateMethod(method)
    "imap & :python pythonHelloWorld()
    normal :python generateCode(a:method)
    "python << EOF
endfunction

command! -nargs=1 GenerateMethod call s:GenerateMethod(<f-args>)
