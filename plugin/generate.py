#!/usr/bin/env python3

def generateMethodReturn(method, attributes, separator=["+"], param=None):
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

def generateMethod(method, return_type, attributes, param=None, separator=["+"]):
    result = list()
    if param:
        result.append("{} {}({} o){}".format(return_type, method, param, '{'))
    else:
        result.append("{} {}(){".format(return_type, method))
    result.append(generateMethodReturn(method, attributes, separator, 'o'))
    result.append("}")
    return result

