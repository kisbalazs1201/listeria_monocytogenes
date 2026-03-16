rule fetch_fastq:
    output:
        "results/input/{accession}.fastq"
    log:
        "logs/fetch/{accession}.log"
    conda:
        "../envs/sra_tools.yaml"
    shell:
        """
        prefetch {wildcards.accession} 2> {log}
        fasterq-dump {wildcards.accession} -O results/input/ 2>> {log}
        rm -r {wildcards.accession}
        """

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
