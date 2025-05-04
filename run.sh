#!/usr/bin/env bash
cd /playpen/hongxuan/DNA_Protein/

# 全局超参数
SEEDS=10
CYCLES=12
STEP=200
SAMPLES=5

# ------------- 逐 DNA × Protein 配对 ------------------------------------------------
for dna_fasta in Sequences/DNA/*.fasta; do
  for protein_fasta in Sequences/Protein/*.fasta; do

    dna_name=$(basename "$dna_fasta" .fasta)
    prot_name=$(basename "$protein_fasta" .fasta)
    run_name="${dna_name}_${prot_name}"

    msa_out="results/msa_results/${run_name}"
    json_out="results/json_results/${run_name}.json"
    af3_out="results/af3_results/${run_name}"
    deeppbs_out="results/deeppbs_results/${run_name}"

    log_dir="results/log_results/${run_name}"
    mkdir -p "$msa_out" "$log_dir" "$(dirname "$json_out")" "$af3_out" "$deeppbs_out"
    log_file="$log_dir/run.log"

    echo "[$(date '+%F %T')] START pipeline ${run_name}" | tee -a "$log_file"
    pipeline_start=$(date +%s)

    # STEP 1: MSA
    step1_start=$(date +%s)
    python Protenix/colabfold_msa.py \
      "$protein_fasta" \
      MSA \
      "$msa_out" \
      --db1 uniref30_2302_db \
      --db3 colabfold_envdb_202108_db \
      --mmseqs_path /home/swyun/.local/bin/mmseqs 2>&1 | tee -a "$log_file"
    step1_end=$(date +%s)
    echo "STEP 1 done in $((step1_end - step1_start))s" | tee -a "$log_file"

    # STEP 2: extract chain dir
    step2_start=$(date +%s)
    msa_chain_dir="$msa_out/msa/0/"
    step2_end=$(date +%s)
    echo "STEP 2 done in $((step2_end - step2_start))s" | tee -a "$log_file"

    # STEP 3: JSON conversion
    step3_start=$(date +%s)
    python Protenix/fasta_to_json.py \
      "$dna_fasta" \
      "$protein_fasta" \
      "$msa_chain_dir" \
      "$json_out" 2>&1 | tee -a "$log_file"
    step3_end=$(date +%s)
    echo "STEP 3 done in $((step3_end - step3_start))s" | tee -a "$log_file"

    # STEP 4: Protenix predict
    step4_start=$(date +%s)
    protenix predict \
      --input "$json_out" \
      --out_dir "$af3_out" \
      --seeds "$SEEDS" \
      --cycle "$CYCLES" \
      --step "$STEP" \
      --sample "$SAMPLES" 2>&1 | tee -a "$log_file"
    step4_end=$(date +%s)
    echo "STEP 4 done in $((step4_end - step4_start))s" | tee -a "$log_file"

    # STEP 5: DeepPBS predict
    step5_start=$(date +%s)
    pred_dir="$af3_out/${run_name}/seed_${SEEDS}/predictions"
    echo $pred_dir
    mkdir -p "${deeppbs_out}/seed_${SEEDS}"
    for sample in $(seq 0 $((SAMPLES - 1))); do
      cif_file="${pred_dir}/${run_name}_seed_${SEEDS}_sample_${sample}.cif"
      echo $cif_file
      [ -f "$cif_file" ] || continue
      docker run --rm -it --gpus all \
        -v "$(pwd)":/app/input \
        -v "$(pwd)/${deeppbs_out}/":/output \
        aricohen/deeppbs:latest \
        "/app/input/${cif_file}"
    done
    step5_end=$(date +%s)
    echo "STEP 5 done in $((step5_end - step5_start))s" | tee -a "$log_file"

    pipeline_end=$(date +%s)
    echo "TOTAL pipeline time: $((pipeline_end - pipeline_start))s" | tee -a "$log_file"
  done
done


# cd /playpen/hongxuan/DNA_Protein/

# dna_fasta="/playpen/hongxuan/DNA_Protein/Sequences/DNA/NANOG_bindingDNA_1.fasta"
# protein_fasta="/playpen/hongxuan/DNA_Protein/Sequences/Protein/CTCF_Protein.fasta"

# SEEDS=10
# CYCLES=12
# STEP=200
# SAMPLES=5

# dna_name=$(basename "$dna_fasta" .fasta)
# prot_name=$(basename "$protein_fasta" .fasta)
# run_name="${dna_name}_${prot_name}"

# msa_out="results/msa_results/${run_name}"
# json_out="results/json_results/${run_name}.json"
# af3_out="results/af3_results/${run_name}"
# deeppbs_out="results/deeppbs_results/${run_name}"

# log_dir="results/log_results/${run_name}"
# mkdir -p "$msa_out" "$log_dir" "$(dirname "$json_out")" "$af3_out" "$deeppbs_out"
# log_file="$log_dir/run.log"

# echo "[$(date '+%F %T')] START pipeline ${run_name}" | tee -a "$log_file"
# pipeline_start=$(date +%s)

# # STEP 1: MSA
# step1_start=$(date +%s)
# python Protenix/colabfold_msa.py \
#   "$protein_fasta" \
#   MSA \
#   "$msa_out" \
#   --db1 uniref30_2302_db \
#   --db3 colabfold_envdb_202108_db \
#   --mmseqs_path /home/swyun/.local/bin/mmseqs 2>&1 | tee -a "$log_file"
# step1_end=$(date +%s)
# echo "STEP 1 done in $((step1_end - step1_start))s" | tee -a "$log_file"

# # STEP 2: extract chain dir
# step2_start=$(date +%s)
# msa_chain_dir="$msa_out/msa/0/"
# step2_end=$(date +%s)
# echo "STEP 2 done in $((step2_end - step2_start))s" | tee -a "$log_file"

# # STEP 3: JSON conversion
# step3_start=$(date +%s)
# python Protenix/fasta_to_json.py \
#   "$dna_fasta" \
#   "$protein_fasta" \
#   "$msa_chain_dir" \
#   "$json_out" 2>&1 | tee -a "$log_file"
# step3_end=$(date +%s)
# echo "STEP 3 done in $((step3_end - step3_start))s" | tee -a "$log_file"

# # STEP 4: Protenix predict
# step4_start=$(date +%s)
# protenix predict \
#   --input "$json_out" \
#   --out_dir "$af3_out" \
#   --seeds "$SEEDS" \
#   --cycle "$CYCLES" \
#   --step "$STEP" \
#   --sample "$SAMPLES" 2>&1 | tee -a "$log_file"
# step4_end=$(date +%s)
# echo "STEP 4 done in $((step4_end - step4_start))s" | tee -a "$log_file"

# # STEP 5: DeepPBS predict
# step5_start=$(date +%s)
# # /playpen/hongxuan/DNA_Protein/results/af3_results/NANOG_bindingDNA_1_NANOG_protein/NANOG_bindingDNA_1_NANOG_protein/seed_10/predictions
# pred_dir="$af3_out/${run_name}/seed_${SEEDS}/predictions"
# echo $pred_dir
# mkdir -p "${deeppbs_out}/seed_${SEEDS}"
# for sample in $(seq 0 $((SAMPLES - 1))); do
#   cif_file="${pred_dir}/${run_name}_seed_${SEEDS}_sample_${sample}.cif"
#   echo $cif_file
#   [ -f "$cif_file" ] || continue
#   docker run --rm -it --gpus all \
#     -v "$(pwd)":/app/input \
#     -v "$(pwd)/${deeppbs_out}/":/output \
#     aricohen/deeppbs:latest \
#     "/app/input/${cif_file}"


# # docker run --rm -it --gpus all \
# #   -v /playpen/hongxuan/DNA_Protein/results/af3_results/NANOG_bindingDNA_1_NANOG_protein/NANOG_bindingDNA_1_NANOG_protein/seed_10/predictions:/app/input \
# #   -v /playpen/hongxuan/DNA_Protein/results/deeppbs_results:/output \
# #   aricohen/deeppbs:latest \
# #   /app/input/NANOG_bindingDNA_1_NANOG_protein_seed_10_sample_5.cif


# done
# step5_end=$(date +%s)
# echo "STEP 5 done in $((step5_end - step5_start))s" | tee -a "$log_file"

# pipeline_end=$(date +%s)
# echo "TOTAL pipeline time: $((pipeline_end - pipeline_start))s" | tee -a "$log_file"
