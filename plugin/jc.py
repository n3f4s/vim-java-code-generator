#!/usr/bin/env python3

import re
import vim

import read
import generate

#TODO : tester
#TODO : faire le dico des methods
#TODO : gestion des erreurs
#TODO : gestion plus poussé de l'analyse (i.e. : savoir dans quelle classe on est ?)

#TODO : savoir comment determiner la méthod à creer (par "ligne de commande" vim)

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
