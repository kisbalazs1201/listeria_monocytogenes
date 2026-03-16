rule download_pharokka_db:
    output:
        "resources/pharokkadbcheck.done"
    conda:
        "../envs/pharokka.yaml"
    log:
        "logs/pharokka/pharokkadbcheck.log"
    params:
        db = config["params"]["pharokka"]["database"]
    shell:
        """
        mkdir -p logs/pharokka
        if [ -d "{params.db}" ] && [ "$(ls -A {params.db})" ]; then
            echo "Pharokka database already exists, skipping download." > {log}
        else
            echo "Downloading Pharokka database..." > {log}
            install_databases.py -o {params.db} >> {log} 2>&1
            if [ ! "$(ls -A {params.db})" ]; then
                echo "ERROR: Database download failed or incomplete!" >> {log}
                exit 1
            fi
            echo "Pharokka database downloaded successfully." >> {log}
        fi
        touch {output}
        """

rule pharokka:
    input:
        fasta = "results/hq/{accession}_hq.fasta",
        db_ready = "resources/pharokkadbcheck.done"
    output:
        directory("results/pharokka/{accession}")
    conda:
        "../envs/pharokka.yaml"
    log:
        "logs/pharokka/{accession}.log"
    threads:
        config["params"]["pharokka"]["threads"]
    params:
        db = config["params"]["pharokka"]["database"]
    shell:
        """
        if [ $(grep -c ">" {input.fasta}) -gt 1 ]; then
            pharokka.py -i {input.fasta} -o {output} -t {threads} -p {wildcards.accession} -d {params.db} -g prodigal-gv -m 2> {log}
        else
            pharokka.py -i {input.fasta} -o {output} -t {threads} -p {wildcards.accession} -d {params.db} -g prodigal-gv 2> {log}
        fi
        """
