# cd /playpen/hongxuan/DNA_Protein/structures
# docker run --rm -it --gpus all \
#   -v $(pwd):/app/input \
#   -v $(pwd)/results:/output \
#   aricohen/deeppbs:latest \
#   /playpen/hongxuan/DNA_Protein/Protenix/structures/Protein-DNA Complex/seed_10/predictions/Protein-DNA Complex_seed_10_sample_0.cif                               # <<< 仅改文件名



docker run --rm -it --gpus all \
  -v /playpen/hongxuan/DNA_Protein/:/app/input \
  -v /playpen/hongxuan/DNA_Protein/predictions/:/output \
  aricohen/deeppbs:latest \
  /app/input/Protenix/structures/try.cif