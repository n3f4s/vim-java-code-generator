
function! s:GenerateMethod(method)
    "imap & :python pythonHelloWorld()
    echo "before generating"
    normal :python generateCode(a:method)
    echo "python script executed"
    "python << EOF
endfunction

command! -nargs=1 GenerateMethod call s:GenerateMethod(<f-args>)
