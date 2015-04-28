#!/usr/bin/env python3

from generate import *
from read import *

if __name__ == '__main__':
    src = open('./Personne.java')

    src_files = src.readlines()

    #variables = getVars(src_files)
    #print("\n".join(generateMethod('equals', 'boolean', variables, 'Object', ['&&','=='])))
    print("\n".join(generateMethod('hashCode', src_files)))
