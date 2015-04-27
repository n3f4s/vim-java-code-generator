#!/usr/bin/env python3

import re
import vim

#TODO : faire le dico des methods
#TODO : gestion plus poussé de l'analyse (i.e. : savoir dans quelle classe on est ?)
#TODO : gestion des erreurs
#TODO : savoir comment determiner la méthod à creer (par "ligne de commande" vim)

def getVarName(line):
    tmp = re.match("^\s*(?:final)? ?(?:(?:public)|(?:private)) \w* (\w*);\s*$", line)
    if tmp:
        return tmp.group(0)
    else:
        return None

def generateMethodReturn(method, attributes, separator=["+"], param=None):
    if not param:
        return separator[0].join([v+"."+method+"()" for v in attributes])
    else:
        return separator[0].join(
                        [ v[0]+separator[-1]+v[1] for v in zip(
                                [v+"."+method+"()" for v in attributes],
                                [param+"."+v+"."+method+"()" for v in attributes]
                            )
                        )

def generateMethod(method, return_type, attributes, param=None, separator=["+"]):
    result = list()
    if param:
        result.append("{} {}({} o){\n".format(return_type, method, param))
    else:
        result.append("{} {}(){\n".format(return_type, method))
    result.append(generateMethodReturn(method, attributes, separator, param))
    result.append("}")
    return result

def getVars(currentBuffer):
    result = list()
    for i in range(len(currentBuffer)):
        tmp = getVarName(currentBuffer[i])
        if tmp:
            result.append(tmp)
    return result

def generateCode(method):
    currentBuffer = vim.current.buffer
    methods = { 'equals': 
        { 
            'return_type' : 'boolean',
            'param'       : 'Object',
            'separator'   : ['&&', '==']
        }
    }
    code = generateMethod(method, methods[method]["return_type"], getVars(currentBuffer), methods[method].get("param", None), methods[method].get("separator", ["+"]))
    (row, _) = vim.current.window.cursor
    currentBuffer.append(code, row)

EOF
