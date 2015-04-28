#!/usr/bin/env python3

import vim

from generate import

#TODO : tester
#TODO : faire le dico des methods
#TODO : gestion des erreurs
#TODO : gestion plus poussé de l'analyse (i.e. : savoir dans quelle classe on est ?)
#TODO : faire un système de template pour la génération de code

def generateCode(method):
    currentBuffer = vim.current.buffer
    row = vim.current.line
    vim.command('echo Beginning generation')
    currentBuffer.append(generateMethod(method, currentBuffer), row)
    vim.command('echo End of generation')


