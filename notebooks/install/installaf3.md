下面给出**最常用的做法**：把 Dockerfile 作为普通文本文件保存，并在需要时重新构建（re-build）镜像。示例以「DeepPBS + Protenix」二合一镜像为例，路径和镜像名字可自行替换。

---

## 1  保存 Dockerfile

1. 任选一个干净目录，例如  
   ```bash
   mkdir -p ~/docker/deeppbs_protenix
   cd ~/docker/deeppbs_protenix
   ```
2. 用喜欢的编辑器创建 **Dockerfile**（文件名必须正是 `Dockerfile`，无扩展名）：  
   ```dockerfile
   # Dockerfile
   FROM aricohen/deeppbs:latest          # 基础镜像
   RUN pip install --no-cache-dir protenix
   ```
   > *如果想用源码版本，把 RUN 行换成 git clone … + pip install -e。*

3. （可选）把整个文件夹加入 **Git** 或其他版本管理，方便团队/多机同步：  
   ```bash
   git init
   git add Dockerfile
   git commit -m "DeepPBS + Protenix v1"
   ```

---

## 2  首次构建

在 Dockerfile 所在目录执行：

```bash
docker build -t deeppbs_protenix:1.0 .
```

- `-t` 指定镜像名和标签（`<name>:<tag>`）；不写标签默认 `latest`。  
- 末尾的 `.` 表示 **构建上下文** = 当前目录。Docker 会把该目录内容（及子目录）发送给 daemon 按 Dockerfile 执行。  
- 构建完成后通过  
  ```bash
  docker images | grep deeppbs_protenix
  ```  
  可看到新镜像。

---

## 3  运行测试

```bash
docker run --rm -it --gpus '"device=0"' \
  -v /my/data:/app/input \
  deeppbs_protenix:1.0 \
  protenix --help
```

确认 Protenix 命令能正常打印帮助信息。

---

## 4  修改后重新构建（rebuild）

1. **编辑 Dockerfile**（或增加新文件、脚本等上下文）。  
2. 再执行一次 `docker build`：  
   ```bash
   docker build -t deeppbs_protenix:1.1 .
   ```
   - 换个 **新标签**（1.1）能保留旧版本；  
   - 若想覆盖旧标签，仍用 `:1.0`，Docker 会用新层替代旧层。  
3. **强制重建忽略缓存**（偶尔需要）：  
   ```bash
   docker build --no-cache -t deeppbs_protenix:1.1 .
   ```

---

## 5  清理旧镜像 / 构建缓存（可选）

- 删除不再需要的镜像：  
  ```bash
  docker rmi deeppbs_protenix:1.0
  ```
- 清理悬空层和构建缓存：  
  ```bash
  docker system prune -af
  ```

---

### 一句话记忆

> **Dockerfile 存成文本 → `docker build -t myimg:tag .` → 改了就再 build（可换新 tag）** —— 就这么简单。