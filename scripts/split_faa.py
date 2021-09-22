#!/usr/bin/env python

import sys
import os
import argparse
import math
from Bio import SeqIO

def splitfasta(args):
    filein = open(args.fasta_file, "r")
    inFasta = list(SeqIO.parse(filein, "fasta"))

    totalSeqs = len(inFasta)
    n = int(math.floor(totalSeqs/args.nsplit))
    nfiles = 0
    dir_out = args.output_dir

    splitSeqs = int(n * (args.nsplit-1))
    for i in range(0, splitSeqs, n):
        nfiles += 1
        newRecord = inFasta[i:i+n]
        newName = os.path.join(dir_out, "proteins_split"+str(nfiles)+".faa")
        SeqIO.write(newRecord, open(newName, "w"), "fasta")

    newRecord = inFasta[splitSeqs:]
    newName = os.path.join(dir_out, "proteins_split"+str(int(args.nsplit))+".faa")
    SeqIO.write(newRecord, open(newName, "w"), "fasta")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Split multi FASTA file')
    parser.add_argument('-f', dest='fasta_file', help='FASTA file to split')
    parser.add_argument('-s', dest='nsplit', type=float, help='Split into how many files')  
    parser.add_argument('-o', dest='output_dir', help='Output directory')   
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    else:
        args = parser.parse_args()
        splitfasta(args)
