#!/usr/bin/env python3

import re

from template import *
from read     import *

def generateMethodReturn_old(method, attributes, separator=["+"], param=None):
    if not param:
        return separator[0].join([v+"."+method+"()" for v in attributes])
    else:
        return str(' '+ separator[0]+' ').join(
                        [ v[0]+'.'+method+'('+v[1]+')' for v in zip(
                                attributes,
                                [param+"."+v for v in attributes]
                            )
                        ]
                    )

def generateMethod_old(method, return_type, attributes, param=None, separator=["+"]):
    result = list()
    if param:
        result.append("{} {}({} o){}".format(return_type, method, param, '{'))
    else:
        result.append("{} {}(){".format(return_type, method))
    result.append(generateMethodReturn(method, attributes, separator, 'o'))
    result.append("}")
    return result

def generateMethodReturn(return_line, attributes):
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
