#! /usr/bin/env python3

import pdb
import argparse
from halo import Halo

def run():
    pdb.set_trace()
    return "hello"

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Do something')
    parser.add_argument("--no-spin",help="Don't spin the spinny spinner",action="store_true")
    args = parser.parse_args()

    if args.no_spin:
        results = run()
    else:
        with Halo(text='', spinner='line'):
            results = run()

    pdb.set_trace()
