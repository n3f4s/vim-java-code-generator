python << EOF

#!/usr/bin/env python3

import re
import vim

#TODO : tester
#TODO : gestion des erreurs
#TODO : gestion plus poussé de l'analyse (i.e. : savoir dans quelle classe on est ?)
#TODO : faire un système de template pour la génération de code

def getTemplate(func):
    funcs = {
        'equals' : [
            'boolean equals(Object o){',
            'return %attr.equals(o.%attr),&&',
            '}'
        ],
        'hashCode' : [
            'int hashCode(){',
            'return %attr.hashCode(),+',
            '}'
        ]
    }
    return funcs[func]

def generateMethodReturn(return_line, attributes):
    echo = "echo 'attributes : ["+','.join(attributes)+"]'"
    vim.command(echo)
    return_tmp = return_line.split(',')
    result = list()
    for elt in attributes:
        result.append(re.sub(r'%attr', elt, return_tmp[0]))
    return 'return ' + str(' '+return_tmp[1]+' ').join(result) + ";"

def generateMethod(method, currentBuffer):
    code = list()
    for line in getTemplate(method):
        tmp = line
        if re.match('return .*', line):
            tmp = generateMethodReturn(line.split(' ')[-1], getVars(currentBuffer))
        code.append(tmp)
    return code


def generateCode(method):
    currentBuffer = vim.current.buffer
    (row,_) = vim.current.window.cursor
    currentBuffer.append(generateMethod(method, currentBuffer), row)

def getVarName(line):
    tmp = re.match("^\s*(?:final)? ?(?:(?:public)|(?:private)) .* (\w*);\s*$", line)
    if tmp:
        return tmp.group(1)
    else:
        return None

def getVars(currentBuffer):
    result = list()
    for i in range(len(currentBuffer)):
        tmp = getVarName(currentBuffer[i])
        if tmp:
            result.append(tmp)
    return result
EOF

function! s:GenerateMethod(method)
    "normal generateCode(a:method)
python << EOF
import vim
generateCode(vim.eval("a:method"))
EOF
endfunction

command! -nargs=1 GenerateMethod call s:GenerateMethod(<f-args>)
