#!/usr/bin/env python3
import json
import sys
import os

def read_fasta_sequence(fasta_file):
    """Read a single‐sequence FASTA file and return the sequence."""
    seq = ""
    print(f"Reading FASTA: {fasta_file}")
    with open(fasta_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('>'):
                continue
            seq += line
    print(f" → length = {len(seq)}")
    return seq

def create_json(protein_seq, dna_seq, msa_dir, output_file, run_name):
    """Create Protenix JSON file with dynamic run_name."""
    if not protein_seq or not dna_seq:
        print("ERROR: Missing protein or DNA sequence!")
        return

    data = [{
        "name": run_name,
        "sequences": [
            {
                "proteinChain": {
                    "sequence": protein_seq,
                    "count": 1,
                    "msa": {
                        "precomputed_msa_dir": msa_dir,
                        "pairing_db": "uniref100"
                    }
                }
            },
            {
                "dnaSequence": {
                    "sequence": dna_seq,
                    "count": 1
                }
            }
        ]
    }]

    try:
        with open(output_file, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"Created JSON: {output_file}")
    except Exception as e:
        print(f"ERROR writing JSON: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python fasta_to_json.py <protein_fasta> <dna_fasta> [msa_directory] [output_json_file]")
        sys.exit(1)

    prot_fasta = sys.argv[2]
    dna_fasta  = sys.argv[1]
    msa_dir    = sys.argv[3] if len(sys.argv) > 3 else "./protenix_msa"
    output_file= sys.argv[4] if len(sys.argv) > 4 else "protein_dna.json"

    prot_base = os.path.splitext(os.path.basename(prot_fasta))[0]
    dna_base  = os.path.splitext(os.path.basename(dna_fasta))[0]
    run_name  = f"{dna_base}_{prot_base}"
    print(f"Run name: {run_name}")

    # 读取序列
    protein_seq = read_fasta_sequence(prot_fasta)
    dna_seq     = read_fasta_sequence(dna_fasta)

    # 生成 JSON
    create_json(protein_seq, dna_seq, msa_dir, output_file, run_name)
