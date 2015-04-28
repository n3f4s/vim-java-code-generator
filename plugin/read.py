#!/usr/bin/env python3

import re

def getVarName(line):
    tmp = re.match("^\s*(?:final)? ?(?:(?:public)|(?:private)) \w* (\w*);\s*$", line)
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
