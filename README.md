# primer3_batch

design batch primers using primer3


### install primer3

primer3 is in conda, lucky you!

```bash
conda install -c bioconda primer3
```

Note, the version on bioconda is not the same as as on github https://github.com/primer3-org/primer3
with different default settings. I have to install from github to make it work.

```bash
git clone https://github.com/primer3-org/primer3.git primer3

cd primer3/src

make

make test
```

read the long mannual http://primer3.org/manual.html


### reference fasta

I use the cellranger mm10 genome fasta file 

```bash
cp  /n/holylfs/INTERNAL_REPOS/INFORMATICS/reference_genome_by_tommy/cellranger_atac_ref/refdata-cellranger-atac-mm10-1.0.1/fasta/genome.fa .
```


### usage

After filtering using the filtering script in `scripts/` folder.

In this example, just take the first 10 regions.

```bash
cat cluster_10_4sample_specific_peak_DNA_with_phylop.tsv | sed '1d' | cut -f1-3 | head > cluster10_peaks.bed
./primer3_batch cluster10_peaks.bed cluster10 mm10.genome genome.fa 150 template.txt cluster10
```

A file named `cluster10_primers.txt` should be created.


Now join it back to the original `cluster_10_4sample_specific_peak_DNA_with_phylop.tsv` file in R:

```{r}
library(tidyverse)

primers<- read_tsv("/Users/mingtang/github_repos/primer3_batch/cluster10_primers.txt", col_names = FALSE)

colnames(primers)<- c("id", "product_size", "forward", "reverse", "forward_plus_cloning", "reverse_plus_cloning")
primers<- primers %>%
        separate(id, into= c("prefix", "seqnames", "start", "end"), extra = "drop") %>%
        mutate_at(vars(c("start", "end")), as.numeric)


original<- read_tsv("/Users/mingtang/github_repos/primer3_batch/cluster_10_4sample_specific_peak_DNA_with_phylop.tsv")

final_result<- inner_join(original, primers)
write_tsv(final_result, "cluster10_primers_final.txt")
```
