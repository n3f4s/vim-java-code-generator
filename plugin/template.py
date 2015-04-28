#!/usr/bin/env python3

def getTemplate(func):
    funcs = {
        'equals' : [
            'boolean equals(Object o){',
            'return %attr.equals(o.%attr),&&',
            '}'
        ],
        'hashCode' : [
            'int hashCode(){',
            'return %attr.hashCode(),+',
            '}'
        ]
    }
    return funcs[func]

