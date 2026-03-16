rule download_checkv_db:
    output:
        "resources/dbcheck.done"
    conda:
        "../envs/checkv.yaml"
    log:
        "logs/checkv/dbcheck.log"
    params:
        db = config["params"]["checkv"]["database"],
        parent = lambda w: str(Path(config["params"]["checkv"]["database"]).parent)
    shell:
        """
        mkdir -p logs/checkv
        if [ -d "{params.db}" ] && [ "$(ls -A {params.db})" ]; then
            echo "CheckV database already exists, skipping download." > {log}
        else
            echo "Downloading CheckV database..." > {log}
            checkv download_database {params.parent} >> {log} 2>&1
            if [ ! "$(ls -A {params.db})" ]; then
                echo "ERROR: Database download failed or incomplete!" >> {log}
                exit 1
            fi
            echo "Database download complete." >> {log}
        fi
        touch {output}
        """

rule checkv:
    input:
        fasta = "results/assembly/{accession}.fasta",
        db_ready = "resources/dbcheck.done"
    output:
        directory("results/checkv/{accession}")
    conda:
        "../envs/checkv.yaml"
    log:
        "logs/checkv/{accession}.log"
    threads:
        config["params"]["checkv"]["threads"]
    params:
        db = config["params"]["checkv"]["database"]
    shell:
        "checkv end_to_end {input.fasta} {output} -d {params.db} -t {threads} 2> {log}"

rule select_hq:
    input:
        checkv   = "results/checkv/{accession}",
        assembly = "results/assembly/{accession}.fasta"
    output:
        tsv = "results/hq/{accession}_hq.tsv",
        fasta = "results/hq/{accession}_hq.fasta"
    conda:
        "../envs/checkv.yaml"
    log:
        "logs/select_hq/{accession}.log"
    shell:
        """
        mkdir -p $(dirname {log})

        awk -F'\\t' 'NR==1 || $9=="High-quality"' {input.checkv}/quality_summary.tsv > {output.tsv} 2> {log}

        awk -F'\\t' 'NR>1 {{print $1}}' {output.tsv} > /tmp/{wildcards.accession}_hq_ids.txt 2>> {log}

        seqtk subseq {input.assembly} /tmp/{wildcards.accession}_hq_ids.txt > {output.fasta} 2>> {log}        
        """
