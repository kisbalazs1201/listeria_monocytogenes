rule filter:
    input:
        "results/input/{accession}.fastq.gz"
    output:
        fastq = "results/filtered/{accession}_filt.fastq.gz",
        html = "results/filtered/{accession}_stats.html",
        json = "results/filtered/{accession}_stats.json",
    conda:
        "../envs/fastplong.yaml"
    log:
        "logs/filter/{accession}.log"
    threads:
        config["params"]["fastplong"]["threads"]
    params:
        min_length = config["params"]["fastplong"]["min_length"],
        min_quality = config["params"]["fastplong"]["min_quality"]
    shell:
        "fastplong -w {threads} -i {input} -l {params.min_length} -m {params.min_quality} --trim_poly_x -o {output.fastq} -h {output.html} -j {output.json} 2> {log}"
