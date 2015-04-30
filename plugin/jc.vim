python << EOF

#!/usr/bin/env python3

import re
import vim
import sys

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
        ],
        'toString' : [
            '@Override',
            'String toString(){',
            'return %attr.toString();+',
            '}'
        ]
    }
    return funcs[func]

class ClassRange:
    def __init__(self, name, begin, end):
        self.name  = name
        self.begin = begin
        self.end   = end
        self.attr  = []

def generateMethodReturn(return_line, attributes, class_name='', wrapper=['','']):
    return_tmp  = return_line.split(';')
    result      = [ re.sub(r'%attr', v, return_tmp[0]) for v in attributes ]
    wrapper[0]  = re.sub(r'%class', class_name, wrapper[0])
    (row,_)     = vim.current.window.cursor
    indent      = int(vim.eval('indent({})'.format(str(row-1))))
    tabStr      = "".join([" "]*indent)
    return tabStr + 'return ' + wrapper[0] + str(' '+return_tmp[1]+' ').join(result) + wrapper[1] + ";"

def nameToIdx(name, classes):
    for idx,elt in enumerate(classes):
        if elt.name == name:
            return idx
    return 0

def parseTemplate(line, row, currentBuffer):
    if re.match('return .*', line):
        match_line = re.match(r'return (.*\()(%attr;.)(\))', line) 
        sub = line.split(' ')[-1]
        wrapper = ['', '']
        if match_line:
            sub = match_line.group(2)
            wrapper = list(match_line.group(1,3))
        classes    = getClasses(currentBuffer)
        variables  = getVars(currentBuffer, classes)
        class_name = getWrapperClass( classes,row )
        class_idx  = nameToIdx(class_name, classes)
        line       = generateMethodReturn(sub, classes[class_idx].attr, class_name, wrapper)
    return line


def generateMethod(method, currentBuffer):
    (row,_) = vim.current.window.cursor
    indent = int(vim.eval('indent({})'.format(str(row-1))))
    tabStr = "".join([" "]*indent)
    return [ tabStr + parseTemplate(line, row, currentBuffer) for line in getTemplate(method) ]

def generateCode(method):
    currentBuffer = vim.current.buffer
    (row,_) = vim.current.window.cursor
    try:
        currentBuffer.append(generateMethod(method, currentBuffer), row)
    except KeyError:
        sys.stderr.write('Unknown method : '+method)
    except IndexError:
        sys.stderr.write('Can\'t generate method out of class')
    #TODO : finir la gestion des exceptions


def getClassName(strLine):
    class_match = re.match('\s*(?:(?:public)|(?:private))? class (\w*)(?: implements .*)? ?{?', strLine)
    class_ = None
    if class_match:
        class_ = class_match.group(1)
    return class_

def getClassRange(line, currentBuffer, className):
    endOfFile = len(currentBuffer)
    numOfBracket = 0
    currentLine = line
    endOfClass = True
    while currentLine < endOfFile and endOfClass:
        if re.search('{', currentBuffer[currentLine]):
            numOfBracket = numOfBracket + 1
        if re.search('}', currentBuffer[currentLine]):
            numOfBracket = numOfBracket - 1
        if numOfBracket == 0:
            endOfClass = False
        currentLine = currentLine + 1
    return ClassRange(className, line, currentLine)

def getClasses(currentBuffer):
    currentLine = 0
    endOfFile = len(currentBuffer)
    classes = []
    while currentLine < endOfFile:
        className = getClassName(currentBuffer[currentLine])
        if className:
            classes.append( getClassRange(currentLine, currentBuffer, className) )
        currentLine = currentLine + 1
    return classes

def getWrapperClass(classes, line):
    idx = 1
    while idx <= len(classes) and (line <= classes[-idx].begin or classes[-idx].end <= line):
        idx=idx+1
    if idx > len(classes):
        raise IndexError
    return classes[-idx].name

def getWrapperClassIdx(classes, line):
    idx = 1
    while idx <= len(classes) and (line <= classes[-idx].begin or classes[-idx].end <= line):
        idx=idx+1
    if idx > len(classes):
        raise IndexError
    return -idx

def getVarName(line):
    tmp = re.match("^\s*(?:final)? ?(?:(?:public)|(?:private)) .* (\w*);\s*$", line)
    if tmp:
        return tmp.group(1)
    else:
        return None

def getVars(currentBuffer, classes):
    idx = 0
    for i in range(len(currentBuffer)):
        tmp = getVarName(currentBuffer[i])
        if tmp:
            idx = getWrapperClassIdx(classes, i)
            classes[idx].attr.append(tmp)
    return idx

def generateClass(args):
    #GenerateClass (public|private)? implements truc<>,machine extend truc
    (row,_)    = vim.current.window.cursor
    name       = vim.current.buffer.name.split('/')[-1].split('.')[0]
    argv       = args.split(' ')
    result     = name
    visibility = 'public'
    implements = ''
    extend     = ''
    idx        = 0
    while idx<len(argv):
        if argv[idx]=='public' or argv[idx]=='private':
            visibility=argv[idx]
        elif re.match('implement',argv[idx], re.IGNORECASE):
            idx = idx + 1
            implements = ' implements ' + re.sub('<>', '<'+name+'>', argv[idx]) + ' '
        elif re.match('extend', argv[idx], re.IGNORECASE):
            idx = idx + 1
            extend = ' extends ' + re.sub('<>', '<'+name+'>', argv[idx]) +' '
        idx = idx + 1
    vim.current.buffer.append(
        [
            visibility+' class  '+name+implements+extend+'{',
            'public '+name+'(){',
            '}',
            '}'
        ],row)

EOF

function! s:GenerateMethod(method)
python << EOF
import vim
generateCode(vim.eval("a:method"))
EOF
endfunction

function! s:GenerateClass(arg)
python << EOF
import vim
generateClass(vim.eval("a:arg"))
EOF
endfunction

function! s:ListAttributes()
python << EOF
import vim
classes = getClasses(vim.current.buffer)
getVars(vim.current.buffer, classes)
string = ''
for c in classes:
    string = string + c.name +'['+str(c.begin)+','+str(c.end)+']' + ' : ' + ",".join(c.attr) + "\n"
vim.command("echo '"+string+"'")
EOF
endfunction

command! -nargs=1 GenerateMethod call s:GenerateMethod(<f-args>)
command! -nargs=0 ListAttributes call s:ListAttributes(<f-args>)
command! -nargs=1 GenerateClass  call s:GenerateClass(<f-args>)
