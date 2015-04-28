python << EOF

#!/usr/bin/env python3

import re
import vim

#TODO : gestion plus poussé de l'analyse (i.e. : savoir dans quelle classe on est ?, classe imbriquée, ...)
#TODO : gestion des erreurs
#TODO : ajouter methodes
#TODO : ajouter doc
#TODO : conservation de l'indentation

def getTemplate(func):
    funcs = {
        'equals' : [
            '@Override',
            'boolean equals(Object o){',
            'return %attr.equals(o.%attr);&&',
            '}'
        ],
        'hashCode' : [
            '@Override',
            'int hashCode(){',
            'return %attr.hashCode();+',
            '}'
        ],
        'clone' : [
            '@Override',
            'Object clone(){',
            'return new %class(%attr;,)',
            '}'
        ]
    }
    return funcs[func]

def generateMethodReturn(return_line, attributes, class_name='', wrapper=['','']):
    echo = "echo 'attributes : ["+','.join(attributes)+"]'"
    vim.command(echo)
    return_tmp = return_line.split(';')
    result = list()
    for elt in attributes:
        result.append(re.sub(r'%attr', elt, return_tmp[0]))
    wrapper[0] = re.sub(r'%class', class_name, wrapper[0])
    return '    return ' + wrapper[0] + str(' '+return_tmp[1]+' ').join(result) + wrapper[1] + ";"

def generateMethod(method, currentBuffer):
    code = list()
    for line in getTemplate(method):
        tmp = line
        if re.match('return .*', line):
            match_line = re.match(r'return (.*\()(%attr;.)(\))', line)
            sub = line.split(' ')[-1]
            wrapper = ['', '']
            if match_line:
                sub = match_line.group(2)
                wrapper = list(match_line.group(1,3))
                #TODO : verifier
            variables  = getVars(currentBuffer)
            class_name = variables.pop()
            tmp = generateMethodReturn(sub, variables, class_name, wrapper)
        (row,_) = vim.current.window.cursor
        tab = 1 #int(vim.current.buffer.options['softtabstop'])
        indent = int(vim.eval('indent({})'.format(str(row-1))))
        tabStr = "".join([" "]*(tab*indent))
        code.append(tabStr + tmp)
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
    class_ = ""
    for i in range(len(currentBuffer)):
        tmp = getVarName(currentBuffer[i])
        if tmp:
            result.append(tmp)
        class_match = re.match('(?:(?:public)|(?:private))? class (\w*)(?: implements .*)? ?{?', currentBuffer[i])
        if class_match:
            class_ = class_match.group(1)
    result.append(class_)
    return result
EOF

function! s:GenerateMethod(method)
python << EOF
import vim
generateCode(vim.eval("a:method"))
EOF
endfunction

command! -nargs=1 GenerateMethod call s:GenerateMethod(<f-args>)
