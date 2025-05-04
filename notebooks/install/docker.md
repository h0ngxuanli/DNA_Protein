下面给出一套 **面向普通 x86-64 Linux（以 Ubuntu 22.04 为例）** 的完整 Docker + NVIDIA Container Toolkit 安装流程，并解释与 Conda 环境的区别，方便你随后拉取并运行 DeepPBS 的镜像。（若你使用 CentOS / RHEL / Rocky / AlmaLinux，请在对应步骤把 `apt` 换成 `dnf` 或 `yum`，其余命令几乎相同。）

---

### 0 . 准备工作

| 条件 | 要点 |
|--|--|
| **操作系统** | 现代 64-bit Linux 发行版（Ubuntu ≥ 20.04、Debian 11、RHEL 8/9 等）。 |
| **内核** | ≥ 3.10；建议 ≥ 5.x（绝大多数发行版满足）。 |
| **权限** | 能使用 `sudo` 或具备 root 权限。 |
| **GPU 使用者** | 已正确安装 **NVIDIA 驱动**（≥ 470.x，最好 535+）。如果只想 CPU 预测，可跳过 GPU 相关步骤。 |

---

## 1 . 安装 Docker Engine

> **如果系统自带 `docker.io` 包，请先卸载**：  
> `sudo apt remove docker docker-engine docker.io containerd runc`

#### 1.1 添加官方仓库

```bash
# 1）安装依赖
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# 2）添加 GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3）写入仓库源（Jammy=22.04；Focal=20.04；自行替换）
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

#### 1.2 安装 Docker

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### 1.3 加入 docker 组（可选，省去 `sudo`）

```bash
sudo usermod -aG docker $USER
newgrp docker  # 重新载入组；或重登一次 shell
```

#### 1.4 验证

```bash
docker run --rm hello-world
```

若输出 *Hello from Docker!*，核心功能已就绪。

---

## 2 . 安装 NVIDIA Container Toolkit（GPU 支持）

> 如果只打算用 **CPU**，整段可跳过。

#### 2.1 添加仓库

```bash
distribution=$(. /etc/os-release; echo $ID$VERSION_ID) # 如 ubuntu22.04
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /etc/apt/keyrings/nvidia-container-toolkit.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list \
    | sed 's#deb https://#deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

#### 2.2 安装并启用

```bash
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

#### 2.3 测试

```bash
docker run --rm --gpus all nvidia/cuda:12.3.0-base-ubuntu22.04 nvidia-smi
```

如果能看到显卡信息与驱动版本，GPU 流水线 OK。

---

## 3 . 获取并运行 DeepPBS 镜像

```bash
# 拉取最新镜像
docker pull aricohen/deeppbs:latest

# 假设当前目录含 test.cif，且希望结果写入 ./results
docker run --gpus all -it \
  -v $(pwd)/test.cif:/app/input/test.cif \
  -v $(pwd)/results:/output \
  aricohen/deeppbs /app/input/test.cif
# 仅预测（不算解释性打分）：
# ... /app/input/test.cif -m
```

完成后，`results` 目录将出现 `predict/`（及可选 `interpretation/`）子目录。

---

## 4 . 常见疑问

| 问题 | 说明 |
|--|--|
| **Docker 与 Conda 有何区别？** | Conda 解决包依赖；Docker 直接封装 *整个* 运行环境（操作系统 + 依赖 + 代码）。Docker 容器之间完全隔离，几乎零冲突，是复现深度学习项目最稳妥的方式。 |
| **需要 root 吗？** | 安装阶段需要 `sudo`；运行容器时加入 `docker` 组即可无 sudo。若集群禁止 Docker，可用 Singularity/Apptainer 转换镜像（见 `singularity build deeppbs.sif docker://aricohen/deeppbs:latest`）。 |
| **驱动版本不匹配？** | 驱动 ≥ 容器内 CUDA 版本即可。DeepPBS 镜像基于 CUDA 12.x，故宿主机驱动建议 ≥ 535.xx。 |
| **Windows / macOS** | Windows 10/11 建议启用 WSL2 并安装 *Docker Desktop*；macOS 直接用 *Docker Desktop*。GPU-passthrough 仅 Windows + WSL2 + 需要 GeForce RTX / A100+。 |

---

### 结语

按照以上步骤，你就可以在本地或服务器上 **零冲突** 地体验 DeepPBS，免去手动编译 PyTorch-Geometric、Torch-Scatter 等棘手依赖的烦恼。如果在驱动、权限或网络（GPG key 步骤）中遇到问题，随时告诉我具体报错，我帮你进一步诊断。祝安装顺利!