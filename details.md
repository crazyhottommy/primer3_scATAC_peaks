### reference fasta

I use the cellranger mm10 genome fasta file 

```bash
cp  /n/holylfs/INTERNAL_REPOS/INFORMATICS/reference_genome_by_tommy/cellranger_atac_ref/refdata-cellranger-atac-mm10-1.0.1/fasta/genome.fa .

cat test.bed
chr16   19839457        19840198
chr13   36736020        36736691
chr13   36733402        36735076
chr2    109677174       109678667
chr7    51623481        51625762
chr7    51621515        51622645
chr5    139543524       139544096
chr13   36726882        36727965
chr10   50894336        50894873
chr5    139550409       139551093

## add column4 as a name to track
cat test.bed | awk -v OFS="\t" '$3=$3"\tcluster_10_"$1"-"$2"-"$3' | tee test2.bed
chr16   19839457        19840198        cluster_10_chr16-19839457-19840198
chr13   36736020        36736691        cluster_10_chr13-36736020-36736691
chr13   36733402        36735076        cluster_10_chr13-36733402-36735076
chr2    109677174       109678667       cluster_10_chr2-109677174-109678667
chr7    51623481        51625762        cluster_10_chr7-51623481-51625762
chr7    51621515        51622645        cluster_10_chr7-51621515-51622645
chr5    139543524       139544096       cluster_10_chr5-139543524-139544096
chr13   36726882        36727965        cluster_10_chr13-36726882-36727965
chr10   50894336        50894873        cluster_10_chr10-50894336-50894873
chr5    139550409       139551093       cluster_10_chr5-139550409-139551093
```

Now, with the bed file get the DNA sequence

first expand the bed file 150bp left and right for the primers.

```bash
## get the genome size file (chromosome length for each chrom)
fetchChromSizes mm10 > mm10.genome

bedtools slop -b 150 -i test2.bed -g mm10.genome | tee test3.bed
chr16   19839307        19840348        cluster_10_chr16-19839457-19840198
chr13   36735870        36736841        cluster_10_chr13-36736020-36736691
chr13   36733252        36735226        cluster_10_chr13-36733402-36735076
chr2    109677024       109678817       cluster_10_chr2-109677174-109678667
chr7    51623331        51625912        cluster_10_chr7-51623481-51625762
chr7    51621365        51622795        cluster_10_chr7-51621515-51622645
chr5    139543374       139544246       cluster_10_chr5-139543524-139544096
chr13   36726732        36728115        cluster_10_chr13-36726882-36727965
chr10   50894186        50895023        cluster_10_chr10-50894336-50894873
chr5    139550259       139551243       cluster_10_chr5-139550409-139551093


bedtools getfasta -fi genome.fa -bed test3.bed  -name -tab -bedOut > test_seq.txt
```

### primer3 input format and parameters

>Primer3Plus is a web interface to Primer3, so if you pick primers with Primer3Plus, it will collect and reformat your input, 
>run the command line tool Primer3, collet and reformats it's output and display it to you.
>In principle, both tools would give you the same output. In practice, the default settings ob both tools differ. 
>While Primer3 default settings are usually kept for backward compatibility, the Primer3Plus default settings are adapted for regular wetlab use.

Let's use the Primer3Plus default

```
  PRIMER_PRODUCT_SIZE_RANGE=501-600 601-700 401-500 701-850 851-1000 1001-1500
                            1501-3000 3001-5000 401-500 301-400 201-300
                            101-200 5001-7000 7001-10000 10001-20000
  PRIMER_SECONDARY_STRUCTURE_ALIGNMENT=1
  PRIMER_NUM_RETURN=10
  PRIMER_MAX_HAIRPIN_TH=47.00
  PRIMER_INTERNAL_MAX_HAIRPIN_TH=47.00
  PRIMER_MAX_END_STABILITY=9.0
  PRIMER_MIN_LEFT_THREE_PRIME_DISTANCE=3
  PRIMER_MIN_RIGHT_THREE_PRIME_DISTANCE=3
  PRIMER_EXPLAIN_FLAG=1
  PRIMER_LIBERAL_BASE=1
  PRIMER_FIRST_BASE_INDEX=1
  PRIMER_MAX_TEMPLATE_MISPRIMING=12.00
  PRIMER_MAX_TEMPLATE_MISPRIMING_TH=47.00
  PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING=24.00
  PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING_TH=47.00
```

prepare a file `primer3_test.txt` add more parameters

Note, the SEQUENCE_TARGET starts at position 151 bp, and extend to the length of the peak.

Also, change `PRIMER_NUM_RETURN=10` to set how many primer pairs you want.
```
SEQUENCE_ID=cluster_10_chr16-19839457-19840198
SEQUENCE_TEMPLATE=TTGAGGTCAGGGATGGTGATTCCCCCAGAACTTCTCTTATTGTTGAGATTAGTTTTCATTATCCTCGGTTTTTTATTGTCCCAAATACTAAGTTTGAGAATTGCTCTTTCTATCTTTTTTGATGGTAGATTGCTTTTGGTAAGATGGCCATTTTTACTGTATTAATCCTACTGATCCATGAGCATGGAAGATCTTTTCGTCTTTTAAGGTCTTTTTCAATTTCTTTCTTCAGAGACTTGAAGTTCTTGTCATACAGATCGTTCACTTGCCTGGTTAGAGTCATATCAAGATTTTCTATTATTTGTGACTATTGTGAAGGGTGTCATTTCCCTAATTTCTTTTTTTAGCCCATTCATCCTTTGAGTAGAATTAATTTTATATCCAGCCCCTTTGCTGAGTATATAACAAGGACACATGCTCCACTTTGTTTATAGCAGCCTTATTTATAATAGCCAGAAGCTGGAAAGAACCCAGATGTCCTTCAACAGAGGAATGAATACTGAAAATGTGGTACATTTACACAATGAAGTACTGCTCAGCTATAAAAAACAAAACAAAAAACAAAAAAAAAGAAAACAATGACTTCATGAAACTCACAGGCAAATGAATGGAACTAGAAAATATCATCCTGAATGAGGTAATCCAGTCACAAAAGAACACAAAGGGTATGTACTCACTGATAAGTGGATATTAGGGCAAAAAGCTCTGAATACACACGGGTAAAAAGCTTGGAATACCCACAATATGACTCACAGACCACATGAGGTTCAAGAAGAAGGAAGACCAAAGTGTGGATGCTTCAGTTCTACTTAGAAGGGGAAACAAAATAATCATGGGAGGTAGAAGGAGGGAGGGAGTGGGAGGGATAAGGGAGGGGAGGGAAAAGAGGGCAGGATAATGTGTGGGGAGAGAAGGGGGAGATGTACAGAGGGGTCAGGAAATTGAACAGAGGTGTGTTGCAGTGGGAATGGGGAACTGGGGGTAGCCACCAGAAAGTTCCAGATGCCAGGAAAGCAAGAGGATCCCAGGACCCAGTGGGAA
PRIMER_TASK=generic
SEQUENCE_TARGET=151,741
PRIMER_PICK_LEFT_PRIMER=1
PRIMER_PICK_INTERNAL_OLIGO=0
PRIMER_PICK_RIGHT_PRIMER=1
PRIMER_OPT_SIZE=20
PRIMER_MIN_SIZE=18
PRIMER_MAX_SIZE=22
PRIMER_PRODUCT_SIZE_RANGE=501-600 601-700 401-500 701-850 851-1000 1001-1500 1501-3000 3001-5000 401-500 301-400 201-300 101-200 5001-7000 7001-10000 10001-20000
PRIMER_SECONDARY_STRUCTURE_ALIGNMENT=1
PRIMER_NUM_RETURN=10
PRIMER_MAX_HAIRPIN_TH=47.00
PRIMER_INTERNAL_MAX_HAIRPIN_TH=47.00
PRIMER_MAX_END_STABILITY=9.0
PRIMER_MIN_LEFT_THREE_PRIME_DISTANCE=3
PRIMER_MIN_RIGHT_THREE_PRIME_DISTANCE=3
PRIMER_EXPLAIN_FLAG=1
PRIMER_LIBERAL_BASE=1
PRIMER_FIRST_BASE_INDEX=1
PRIMER_MAX_TEMPLATE_MISPRIMING=12.00
PRIMER_MAX_TEMPLATE_MISPRIMING_TH=47.00
PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING=24.00
PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING_TH=47.00
=
```

Design one primer for one sequence:

```bash
primer3_core primer3_test.txt --format_out

PRIMER PICKING RESULTS FOR cluster_10_chr16-19839457-19840198

No mispriming library specified
Using 1-based sequence positions
OLIGO            start  len      tm     gc%  any_th  3'_th hairpin seq
LEFT PRIMER        131   20   57.70   45.00    8.56   8.56    0.00 TGCTTTTGGTAAGATGGCCA
RIGHT PRIMER       924   20   60.03   60.00    0.00   0.00    0.00 ACATCTCCCCCTTCTCTCCC
SEQUENCE SIZE: 1041
INCLUDED REGION SIZE: 1041

PRODUCT SIZE: 794, PAIR ANY_TH COMPL: 0.00, PAIR 3'_TH COMPL: 0.00
TARGETS (start, len)*: 151,741
```

### write a python function to format the input for every DNA sequence


```python

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
        target_length = int(end) - int(start) - 2* padding
        new_string = template_string.format(id = id, seq = seq, start = padding, length = target_length)
        with open("{id}_primer3_input.txt".format(id = id), "w") as ofile:
            ofile.write(new_string)
            ofile.close()

```

use it on commandline:

prepare a template `primer3_test.txt`.
Note the {}, this will be replaced by the information in the test_seq.txt file.
```bash

cat primer3_test.txt 

SEQUENCE_ID={id}
SEQUENCE_TEMPLATE={seq}
PRIMER_TASK=generic
SEQUENCE_TARGET={start},{length}
PRIMER_PICK_LEFT_PRIMER=1
PRIMER_PICK_INTERNAL_OLIGO=0
PRIMER_PICK_RIGHT_PRIMER=1
PRIMER_OPT_SIZE=20
PRIMER_MIN_SIZE=18
PRIMER_MAX_SIZE=22
PRIMER_PRODUCT_SIZE_RANGE=501-600 601-700 401-500 701-850 851-1000 1001-1500 1501-3000 3001-5000 401-500 301-400 201-300 101-200 5001-7000 7001-10000 10001-20000
PRIMER_SECONDARY_STRUCTURE_ALIGNMENT=1
PRIMER_NUM_RETURN=1
PRIMER_MAX_HAIRPIN_TH=47.00
PRIMER_INTERNAL_MAX_HAIRPIN_TH=47.00
PRIMER_MAX_END_STABILITY=9.0
PRIMER_MIN_LEFT_THREE_PRIME_DISTANCE=3
PRIMER_MIN_RIGHT_THREE_PRIME_DISTANCE=3
PRIMER_EXPLAIN_FLAG=1
PRIMER_LIBERAL_BASE=1
PRIMER_FIRST_BASE_INDEX=1
PRIMER_MAX_TEMPLATE_MISPRIMING=12.00
PRIMER_MAX_TEMPLATE_MISPRIMING_TH=47.00
PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING=24.00
PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING_TH=47.00
=
```

```bash
./primer3_batch.sh test.bed cluster10 mm10.genome genome.fa 150 template.txt firstTry
```
