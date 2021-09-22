import os

configfile: 'config/config.yml'
ncores = config['ncores']
splits = config['nsplits']
db_dir = config['db_dir']

INPUT_FILE = config['input_file']
OUTPUT_DIR = config['output_dir']

directs = [OUTPUT_DIR, OUTPUT_DIR+"/logs/eggnog",
           OUTPUT_DIR+"/logs/cazy", OUTPUT_DIR+"/logs/kofam"] 

for direct in directs:
    if not os.path.exists(direct):
        os.makedirs(direct)

os.system("chmod -R +x scripts")

rule targets:
    input:
        OUTPUT_DIR+"/summary/eggNOG_annotations.tsv",
        OUTPUT_DIR+"/summary/KOFam_annotations.tsv",
        OUTPUT_DIR+"/summary/CAZy_annotations.tsv"

rule split_fasta:
    input:
        INPUT_FILE
    output:
        outdir = directory(OUTPUT_DIR+"/splits/"),
        faas = expand(OUTPUT_DIR+"/splits/proteins_split{n}.faa", n=list(range(1, splits+1)))
    params:
        nsplits = splits
    conda:
        "config/envs/biopython.yml"
    shell:
        "python scripts/split_faa.py -f {input} -s {params.nsplits} -o {output.outdir}"

rule eggnog:
    input:
        OUTPUT_DIR+"/splits/proteins_split{n}.faa"
    output:
        outfile = OUTPUT_DIR+"/eggnog/split{n}/eggnog.emapper.annotations",
    params:
        out = OUTPUT_DIR+"/eggnog/split{n}",
        db = db_dir+"/eggnog"
    conda:
        "config/envs/emapper.yml"
    resources:
        ncores = ncores
    shell:
        "emapper.py --cpu {resources.ncores} -i {input} -m diamond -o eggnog --output_dir {params.out} --temp_dir {params.out} --data_dir {params.db}"

rule cazy:
    input:
        OUTPUT_DIR+"/splits/proteins_split{n}.faa"
    output:
        OUTPUT_DIR+"/cazy/split{n}/overview.txt"
    params:
        out = OUTPUT_DIR+"/cazy/split{n}",
        db = db_dir+"/cazy"
    conda: 
        "config/envs/dbcan.yml"
    resources:
        ncores = ncores
    shell:
        """
        run_dbcan.py --dia_cpu {resources.ncores} --hmm_cpu {resources.ncores} --tf_cpu {resources.ncores} --hotpep_cpu {resources.ncores} {input} protein --db_dir {params.db} --out_dir {params.out}
        """

rule kofam:
    input:
        OUTPUT_DIR+"/splits/proteins_split{n}.faa"
    output:
        OUTPUT_DIR+"/kofam/split{n}/kofam-parsed.tsv"
    params:
        out = OUTPUT_DIR+"/kofam/split{n}",
        db = db_dir+"/kofam/kofam_db.hmm"
    conda:
        "config/envs/biopython.yml"
    resources:
        ncores = ncores
    shell:
        "python scripts/kofamscan.py -t {resources.ncores} -q {input} -o {params.out} -d {params.db}"

rule summarize:
    input:
        eggnog = expand(OUTPUT_DIR+"/eggnog/split{n}/eggnog.emapper.annotations", n=list(range(1, splits+1))),
        cazy = expand(OUTPUT_DIR+"/cazy/split{n}/overview.txt", n=list(range(1, splits+1))),
        kofam = expand(OUTPUT_DIR+"/kofam/split{n}/kofam-parsed.tsv", n=list(range(1, splits+1)))
    output:
        eggnog = OUTPUT_DIR+"/summary/eggNOG_annotations.tsv",
        cazy = OUTPUT_DIR+"/summary/CAZy_annotations.tsv",
        kofam = OUTPUT_DIR+"/summary/KOFam_annotations.tsv"
    shell:
        """
        grep -v '^#' {input.eggnog} | cut -f2 -d ':' > {output.eggnog}
        grep -wv Hotpep {input.cazy} | cut -f2 -d ':' > {output.cazy}
        cat {input.kofam} > {output.kofam}
        """
