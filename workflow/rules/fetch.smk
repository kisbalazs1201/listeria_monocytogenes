rule download:
    output:
        "data/{sample}.fastq"

rule compress_fastq:
    input:
        "results/input/{accession}.fastq"
    output:
        "results/input/{accession}.fastq.gz"
    log:
        "logs/compress/{accession}.log"
    conda:
        "../envs/sra_tools.yaml"
    shell:
        "gzip -c {input} > {output} 2> {log}"
