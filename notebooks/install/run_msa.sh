
# 配置colabfold的环境
cd /playpen/hongxuan/DNA_Protein/Protenix
wget https://raw.githubusercontent.com/bytedance/Protenix/main/scripts/colabfold_msa.py
which mmseqs
pip install "colabfold[alphafold]"
# run msa，使用colabfold的代码
python colabfold_msa.py \
  /playpen/hongxuan/DNA_Protein/sequences/pair.fasta \
  /playpen/hongxuan/DNA_Protein/MSA \
  /playpen/hongxuan/DNA_Protein/Protenix/msa_results \
  --db1 uniref30_2302_db \
  --db3 colabfold_envdb_202108_db \
  --mmseqs_path /home/swyun/miniconda3/bin/mmseqs \
  --threads 64

colabfold_search   /playpen/hongxuan/DNA_Protein/sequences/pair.fasta   /playpen/hongxuan/DNA_Protein/MSA   /playpen/hongxuan/DNA_Protein/Protenix/msa_results   --db1 uniref30_2302_db   --db3 colabfold_envdb_202108_db   --use-env 1   --mmseqs /home/swyun/miniconda3/bin/mmseqs   --threads 1

sudo rm -rf /playpen/hongxuan/DNA_Protein/Protenix/msa_results/*


docker run --gpus all \
  -v /playpen/hongxuan/DNA_Protein/sequences:/work/sequences:ro \
  -v /playpen/hongxuan/DNA_Protein/MSA:/work/MSA:ro \
  -v /playpen/hongxuan/DNA_Protein/Protenix/msa_results:/work/msa_results:rw \
  ghcr.io/sokrypton/colabfold:1.5.5-cuda12.2.2 \
  colabfold_search \
    /work/sequences/pair.fasta \
    /work/MSA \
    /work/msa_results \
    --db1 uniref30_2302_db \
    --db3 colabfold_envdb_202108_db \
    --use-env 1 \
    --threads 128