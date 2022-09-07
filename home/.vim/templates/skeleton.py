#! /usr/bin/env python3

import pdb
import argparse
from halo import Halo
import os
import logging

def run():
    pdb.set_trace()
    return "hello"

if __name__ == "__main__":

    log = logging.getLogger(__name__)
    log.debug("Starting: "+__name__)

    parser = argparse.ArgumentParser(description='Do something')
    parser.add_argument("--no-spin",help="Don't spin the spinny spinner",action="store_true")
    parser.add_argument("--truefalse",help="true / false switch",action="store_true")
    parser.add_argument("--list",metavar='item',nargs='+',help="List of args into an array",type=str)
    cli_args = parser.parse_args()

    if cli_args.no_spin:
        results = run()
    else:
        with Halo(text='', spinner='line'):
            results = run()

    pdb.set_trace()
