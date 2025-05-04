Below is a **minimal, self-contained tutorial** that reproduces the workflow you just ran—from a clean server to interpretable DeepPBS results—without extra Docker jargon.

---

## 0.  环境前提

| 组件 | 版本 / 说明 | 检查命令 |
|------|-------------|----------|
| Linux x86-64 + Docker | Docker ≥ 20.10 | `docker run --rm hello-world` |
| GPU (可选) | 已装 NVIDIA 驱动 + nvidia-container-toolkit | `nvidia-smi` & `docker run --rm --gpus all nvidia/cuda:12.3.0-base-ubuntu22.04 nvidia-smi` |
| 结构文件 | `.pdb` 或 `.cif` | 确认文件存在 |

---

## 1.  首次拉取镜像（只需一次）

```bash
docker pull aricohen/deeppbs:latest
```

---

## 2.  准备目录与输入

```bash
# 任意放置你的结构文件，这里示例路径：
mkdir -p /playpen/hongxuan/DNA_Protein/results
cp 5x6g.cif /playpen/hongxuan/DNA_Protein/          # 换成自己的文件
```

目录结构示例：

```
DNA_Protein/
├── 5x6g.cif
└── results/
```

---

## 3.  单文件推理命令

```bash
cd /playpen/hongxuan/DNA_Protein

docker run --rm -it --gpus all \                    # CPU 则删掉此参数
  -v $(pwd):/app/input \                            # 输入目录
  -v $(pwd)/results:/output \                       # 输出目录
  aricohen/deeppbs:latest \
  /app/input/5x6g.cif                               # <<< 仅改文件名
```

完成后，结果出现在 `results/` ：

```
results/
├─ predict/                # 预测分数、PWM
└─ interpretation/         # PyMOL 会话、残基重要性等（若未加 -m）
```

---

## 4.  可选参数

| 需求 | 选项 & 示例 |
|------|-------------|
| **只预测，不做解释** | 在命令最后加 `-m` |
| **指定 GPU 0** | `--gpus '"device=0"'` |
| **随机使用 1 张 GPU** | `--gpus '"count=1"'` |
| **避免 root 权限写文件** | 再加 `--user $(id -u):$(id -g)` |
| **CPU 推理** | 删除 `--gpus …` 整段 |

---

## 5.  批量推理脚本（示例）

```bash
cd /playpen/hongxuan/DNA_Protein
for f in *.cif *.pdb; do
  docker run --rm --gpus '"device=0"' \
    -v $(pwd):/app/input \
    -v $(pwd)/results:/output \
    aricohen/deeppbs:latest \
    /app/input/"$f"
done
```

---

## 6.  常见问题速查

| 报错 / 现象 | 解决 |
|-------------|------|
| `file not found` | 文件名或路径不一致；确认 `ls /path/file.cif` 存在并与命令匹配。 |
| `invalid reference format` | 换行符号写错：反斜杠 `\` 后**不能有空格**。 |
| 图中字体警告 / Helvetica 缺失 | 仅影响字体外观，可忽略。 |
| PyMOL `.png` 正常但提示 *unsupported file type* | `.psw` 保存失败无害；PNG 已生成。 |

---

### 所有步骤到此结束——每次重新登录服务器，只需重复 **第 3 步命令**（换文件名即可），其余无需重新安装或配置。