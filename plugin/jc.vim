python << EOF

#!/usr/bin/env python3

import re
import vim

#TODO : advanced analysis of context (class and nested class, ....)
#TODO : error managing
#TODO : add more method ?
#TODO : add doc

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
    (row,_) = vim.current.window.cursor
    indent = int(vim.eval('indent({})'.format(str(row-1))))
    tabStr = "".join([" "]*indent)
    return tabStr + 'return ' + wrapper[0] + str(' '+return_tmp[1]+' ').join(result) + wrapper[1] + ";"

def generateMethod(method, currentBuffer):
    code = list()
    (row,_) = vim.current.window.cursor
    indent = int(vim.eval('indent({})'.format(str(row-1))))
    tabStr = "".join([" "]*indent)
    for line in getTemplate(method):
        tmp = line
        if re.match('return .*', line):
            match_line = re.match(r'return (.*\()(%attr;.)(\))', line)
            sub = line.split(' ')[-1]
            wrapper = ['', '']
            if match_line:
                sub = match_line.group(2)
                wrapper = list(match_line.group(1,3))
            variables  = getVars(currentBuffer)
            class_name = getWrapperClass( getClasses(currentBuffer),row )
            tmp = generateMethodReturn(sub, variables, class_name, wrapper)
        code.append(tabStr + tmp)
    return code

def generateCode(method):
    currentBuffer = vim.current.buffer
    (row,_) = vim.current.window.cursor
    currentBuffer.append(generateMethod(method, currentBuffer), row)


def getClassName(strLine):
    class_match = re.match('(?:(?:public)|(?:private))? class (\w*)(?: implements .*)? ?{?', strLine)
    class_ = None
    if class_match:
        class_ = class_match.group(1)
    return class_

def getClassRange(line, currentBuffer):
    endOfFile = len(currentBuffer)
    numOfBracket = 0
    currentLine = line
    endOfClass = False
    while currentLine < endOfFile and endOfClass:
        if re.match('.*{.*', currentBuffer[currentLine]):
            numOfBracket = NumOfBracket + 1
        if re.match('.*}.*', currentBuffer[currentLine]):
            numOfBracket = NumOfBracket - 1
        if numOfBracket == 0:
            endOfClass = True
        currentLine = currentLine + 1
    return (line, currentLine)

def getClasses(currentBuffer):
    currentLine = 0
    endOfFile = len(currentBuffer)
    classes = []
    while currentLine < endOfFile:
        className = getClassName(currentBuffer[currentLine])
        if className:
            classes.append( (className , getClassRange(currentLine, currentBuffer)) )
            currentLine = classes[-1][-1][-1]
        currentLine = currentLine + 1
    return classes

def getWrapperClass(classes, line):
    idx = 1
    while idx <= len(classes) and line not in range(classes[-idx][-1][0],classes[-idx][-1][1]+1):
        idx=idx+1
        echo = "echo " + "'" + classes[-idx][0] + "'"
        vim.command(echo)
    return classes[-idx][0]

def getVarName(line):
    tmp = re.match("^\s*(?:final)? ?(?:(?:public)|(?:private)) .* (\w*);\s*$", line)
    if tmp:
        return tmp.group(1)
    else:
        return None

def getVars(currentBuffer):
    result = list()
    #class_ = ""
    for i in range(len(currentBuffer)):
        tmp = getVarName(currentBuffer[i])
        if tmp:
            result.append(tmp)
        #class_match = re.match('(?:(?:public)|(?:private))? class (\w*)(?: implements .*)? ?{?', currentBuffer[i])
        #if class_match:
        #    class_ = class_match.group(1)
    #result.append(class_)
    return result
EOF

function! s:GenerateMethod(method)
python << EOF
import vim
generateCode(vim.eval("a:method"))
EOF
endfunction

command! -nargs=1 GenerateMethod call s:GenerateMethod(<f-args>)
