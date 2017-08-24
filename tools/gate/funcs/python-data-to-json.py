#!/usr/bin/env python
import json
import sys

def dump(s):
    print json.dumps(eval(s))

def main(args):
    if not args:
        dump(''.join(sys.stdin.readlines()))
    else:
        for arg in args:
            dump(''.join(open(arg, 'r').readlines()))
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
