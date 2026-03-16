rule assembly:
    input:
        "results/filtered/{accession}_filt.fastq.gz"
    output:
        "results/assembly/{accession}.fasta",
    conda:
        "../envs/raven.yaml"
    log:
        "logs/assembly/{accession}.log"
    threads:
        config["params"]["raven"]["threads"]
    shell:
        "raven -t {threads} --disable-checkpoints {input} > {output} 2> {log}"
