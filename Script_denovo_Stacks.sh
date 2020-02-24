#!/bin/bash
#SBATCH --partition mpcb.p
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 16
#SBATCH --exclusive
#SBATCH --time 3-0:00:00
#SBATCH --mem-per-cpu 8000
#SBATCH --job-name tunnel
#SBATCH --output gstacksnovoSuite-log-%J.txt

## Activate stacks

conda activate py37env


## Rename files according to script

for f in *.fastq.gz; do mv "$f" "${f%.*.fastq.gz}.fastq.gz" ; done
##radtags

for sample in *_R1_.fastq.gz*; do
base=$(basename $sample "_R1_.fastq.gz")
process_radtags -1 ${base}_R1_.fastq.gz -2 ${base}_R2_.fastq.gz -c -q -E phred33 -e mslI -o Data/output_clean_denovo/ 
done

##remove _R2_ on file name 

for filename in *_R2_.2.fq.gz*;
      do  [ -f "$filename" ] || continue;  
      mv "$filename" "${filename//_R2_/}";
      done

##ustacks

id=1
for sample in *_R1_.1.fq.gz* 
do 
base=$(basename $sample "_R1_.1.fq.gz")
ustacks -f ${base}_R1_.1.fq.gz -o Data/output_clean_denovo/denovopopmap/Map2.txt -i $id --name ${base} -M 4 --max_locus_stacks 5 -p 8 
let "id+=1"
done


##cstacks

cstacks -n 6 -P Data/output_clean_denovo/output_ustacks1/ -M Data/output_clean_denovo/denovopopmap/Map2.txt -p 12


##sstacks
sstacks -P Data/output_clean_denovo/output_ustacks1/ -M Data/output_clean_denovo/denovopopmap/Map2.txt -p 12


##tsv2bam


tsv2bam -P Data/output_clean_denovo/output_ustacks1/ -M ./denovopopmap/Map1.txt --pe-reads-dir Data/output_clean_denovo/ -t 14

##
gstacks -P  Data/output_clean_denovo/output_ustacks1/ -M Data/output_clean_denovo/denovopopmap/Map2.txt --rm-pcr-duplicates -t14

populations -P Data/output_clean_denovo/output_ustacks1/  -M Data/output_clean_denovo/denovopopmap/Map2.txt -R 0.01 -f p_value --vcf --genepop --structure --write-single-snp -t 8 -O  Data/output_clean_denovo/out_structnovo_1
populations -P Data/output_clean_denovo/output_ustacks1/  -M Data/output_clean_denovo/denovopopmap/Map2.txt -R 0.75 -f p_value --vcf --genepop --structure --write-single-snp -t 8 -O  Data/output_clean_denovo/out_structnovo_75
populations -P Data/output_clean_denovo/output_ustacks1/  -M Data/output_clean_denovo/denovopopmap/Map2.txt -R 0.50 -f p_value --vcf --genepop --structure --write-single-snp -t 8 -O  Data/output_clean_denovo/out_structnovo_50
populations -P Data/output_clean_denovo/output_ustacks1/  -M Data/output_clean_denovo/denovopopmap/Map2.txt -R 0.25 -f p_value --vcf --genepop --structure --write-single-snp -t 8 -O  Data/output_clean_denovo/out_structnovo_25
populations -P Data/output_clean_denovo/output_ustacks1/  -M Data/output_clean_denovo/denovopopmap/Map2.txt -R 0.10 -f p_value --vcf --genepop --structure --write-single-snp -t 8 -O  Data/output_clean_denovo/out_structnovo_10


populations -P Data/output_clean_denovo/output_ustacks1/  -M Data/output_clean_denovo/denovopopmap/Map2.txt -R 0.01 -e mslI --vcf --genepop --fstats  --phylip --treemix --smooth --hwe -t 8 -O Data/output_clean_denovo/out_structnovo_phy1
populations -P Data/output_clean_denovo/output_ustacks1/  -M Data/output_clean_denovo/denovopopmap/Map2.txt -R 0.75 -e mslI --vcf --genepop --fstats  --phylip --treemix --smooth --hwe -t 8 -O Data/output_clean_denovo/out_structnovo_phy75
populations -P Data/output_clean_denovo/output_ustacks1/  -M Data/output_clean_denovo/denovopopmap/Map2.txt -R 0.50 -e mslI --vcf --genepop --fstats  --phylip --treemix --smooth --hwe -t 8 -O Data/output_clean_denovo/out_structnovo_phy50
populations -P Data/output_clean_denovo/output_ustacks1/  -M Data/output_clean_denovo/denovopopmap/Map2.txt -R 0.25 -e mslI --vcf --genepop --fstats  --phylip --treemix --smooth --hwe -t 8 -O Data/output_clean_denovo/out_structnovo_phy25
populations -P Data/output_clean_denovo/output_ustacks1/  -M Data/output_clean_denovo/denovopopmap/Map2.txt -R 0.10 -e mslI --vcf --genepop --fstats  --phylip --treemix --smooth --hwe -t 8 -O Data/output_clean_denovo/out_structnovo_phy10


