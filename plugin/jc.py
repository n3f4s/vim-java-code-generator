#!/usr/bin/env python3

import re
import vim

from read     import *
from generate import
from template import *

#TODO : tester
#TODO : faire le dico des methods
#TODO : gestion des erreurs
#TODO : gestion plus poussé de l'analyse (i.e. : savoir dans quelle classe on est ?)
#TODO : faire un système de template pour la génération de code

def generateCode(method):
    currentBuffer = vim.current.buffer
    methods = { 'equals': {
            'return_type' : 'boolean',
            'param'       : 'Object',
            'separator'   : ['&&', '==']
            }, 'hashCode' : {
                'return_type' : 'int',
                'separator'   : ['+']
            }
    }
    code = generateMethod(method, methods[method]["return_type"], getVars(currentBuffer), methods[method].get("param", None), methods[method].get("separator", ["+"]))
    (row, _) = vim.current.window.cursor
    currentBuffer.append(code, row)
