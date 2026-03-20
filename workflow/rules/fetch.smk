rule download:
    output:
        "data/{sample}.fastq"

rule filter:
    input:
        "data/{sample}.fastq"
    output:
        "data/filtered/{sample}.fastq"

rule assembly:
    input:
        "data/filtered/{sample}.fastq"
    output:
        "results/{sample}/assembly.fasta"
