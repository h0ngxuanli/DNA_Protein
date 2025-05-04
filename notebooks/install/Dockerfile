FROM aricohen/deeppbs:latest
RUN apt-get update && \
    apt-get install -y --no-install-recommends cuda-toolkit-12-1 && \
    rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir --no-deps protenix
RUN pip install click
RUN pip install rdkit
RUN pip install ml_collections
RUN pip install PyYaml
RUN pip install scipy
RUN pip install ml_collections
RUN pip install tqdm
RUN pip install pandas
RUN pip install optree
RUN pip install rdkit
RUN pip install biopython==1.83
RUN pip install modelcif==0.7
RUN pip install biotite==1.0.1
RUN pip install scikit-learn
RUN pip install scikit-learn-extra

RUN pip install protobuf==3.20.2
RUN pip install icecream
RUN pip install ipdb
RUN pip install wandb
RUN pip install numpy==1.26.3
RUN pip install matplotlib==3.9.2
RUN pip install ipywidgets
RUN pip install py3Dmol
# RUN pip install deepspeed>=0.15.1
# RUN pip install nvidia-cublas-cu12
# RUN pip install torch==2.3.1
    # nvidia-cublas-cu12 \
    # torch==2.3.1

# cd /playpen/hongxuan/DNA_Protein/install
# docker build -t deeppbs_protenix . 