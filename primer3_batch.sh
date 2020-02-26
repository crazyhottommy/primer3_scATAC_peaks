#! /bin/bash

set -euo pipefail

show_help() {
cat << EOF
From a bed file with three columns: chr, start, end
add a fourth column with prefix_chr-start-end
pad 150 bp upstream and downstream, extract the DNA sequence
and make a primer3 input file by using a Boulder IO <template> for 
each sequence.

Usage: ${0##*/} <bed file> <prefix> <genomeSize> <genomeFasta> <padding> <template> <outName>
Example: ${0##*/} test.bed cluster10 mm10.genome genome.fa 150 template.txt mytest
EOF
}


## check the number of inputs
if [[ $# -ne 7 ]];then show_help;exit 1;fi


## check bedtools primer3 installed or not
((command -v bedtools) > /dev/null) || \
(echo "bedtools is not in your  $PATH, \
    install it by 'conda install -c bioconda bedtools'" && exit 1)


((command -v primer3_core) > /dev/null) || \
(echo "primer3_core is not in your  $PATH, \
    install it by 'conda install -c bioconda primer3'" && exit 1)


bed=$1
prefix=$2
genomeSize=$3
genomeFasta=$4
padding=$5
template=$6
outName=$7



cat "${bed}" | \
awk -v OFS="\t" -v prefix="${prefix}" '$3=$3"\t" prefix"-"$1"-"$2"-"$3' | \
bedtools slop -b "${padding}" -i - -g $genomeSize | \
bedtools getfasta -fi "${genomeFasta}" -bed - -name -bedOut > "${outName}"_seq.txt

./prepare_primer3_input.py "${outName}"_seq.txt "${template}" --padding_length "${padding}"



## design primers for each DNA sequence

for input in *primer3-input.txt
do
    echo "designing primers for ${input}"
    primer3_core $input --output ${input/input/output}
done

echo "combining all primers into a single file and adding the cloning sequence."

grep "PRIMER_LEFT_0_SEQUENCE=" *primer3-output.txt | tr ":" "\t" | sort > left_primers.txt
grep "PRIMER_RIGHT_0_SEQUENCE=" *primer3-output.txt | tr ":" "\t"| sort > right_primers.txt
grep "PRIMER_PAIR_0_PRODUCT_SIZE=" *primer3-output.txt | tr ":" "\t" | sort > product_size.txt

join left_primers.txt right_primers.txt | \
join product_size.txt - | \
tr " " "\t" | sed 's/PRIMER_LEFT_0_SEQUENCE=//' | \
sed 's/PRIMER_PAIR_0_PRODUCT_SIZE=//' | \
sed 's/PRIMER_RIGHT_0_SEQUENCE=//' | \
awk -v OFS="\t" '$5="GCCGCACGCGTTTAAT"$3' | \
#awk -v OFS="\t" '{"echo "$3 "| rev" | getline $5}{print $0}' | \  #no need to reverse.
awk -v OFS="\t" '$6="GCGATCGCTTGTCGAC"$4' > ${outName}_primers.txt

echo "cleanning up intermeidate files"
rm *primer3-input.txt *primer3-output.txt
rm left_primers.txt right_primers.txt

echo
echo "check ${outName}_primers.txt for the primers! if it looks good, send beers to tangming2005@gmail.com"
echo "if no luck, bug him at tangming2005@gmail.com"

