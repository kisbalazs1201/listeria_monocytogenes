with open(config["accessions"]) as f:
    accessions = [line.strip() for line in f if line.strip() and not line.startswith("#")]
