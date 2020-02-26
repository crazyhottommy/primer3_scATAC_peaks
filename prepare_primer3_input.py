#! /usr/bin/env python3


import csv
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("input", help="Required. the FULL path to the 2 column input file, first column is the ID, second column is the DNA sequence")
parser.add_argument("primer3_template", help="primer3 Boulder-IO format template txt file. see http://primer3.org/manual.html#inputOutputConventions")
parser.add_argument("--padding_length", default = 150, help="padding sequence length for the target, default 150 bp")
args = parser.parse_args()

assert args.input is not None, "please provide the path to the input file"
assert args.primer3_template is not None, "please provide the path to the primer3 Boulder-IO template file"

padding = args.padding_length

template = open(args.primer3_template, "r")
template_string = template.read()
template.close()

with open(args.input, "r") as ifile:
    reader = csv.reader(ifile, delimiter = "\t")
    for row in reader:
        chr = row[0]
        start = row[1]
        end = row[2]
        id = row[3]
        seq = row[4]
        seq_length = len(seq)
        target_length = int(end) - int(start) - 2* int(padding)
        new_string = template_string.format(id = id, seq = seq, start = padding, length = target_length)
        with open("{id}-primer3-input.txt".format(id = id), "w") as ofile:
            ofile.write(new_string)
            ofile.close()




