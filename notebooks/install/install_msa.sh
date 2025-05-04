# 创建临时容器并复制mmseqs2二进制文件
container_id=$(docker create ghcr.io/sokrypton/colabfold:1.5.5-cuda12.2.2)
docker cp $container_id:/usr/local/envs/colabfold/bin/mmseqs ~/.local/bin/
docker rm $container_id

# 确保~/.local/bin在PATH中
mkdir -p ~/.local/bin
echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc