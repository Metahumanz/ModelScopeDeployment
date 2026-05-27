# 大语言模型部署体验与横向对比实验

## 快速开始

在 ModelScope Notebook 的 Terminal 中执行：

```bash
cd /mnt/workspace
git clone https://github.com/<your-name>/<your-repo>.git
cd <your-repo>
bash setup_modelscope.sh
bash run_tests.sh
```

`setup_modelscope.sh` 用于检查 Python 环境并安装依赖；`run_tests.sh` 会统一运行默认模型测试。

## 运行全部测试

默认测试两个适合 CPU 环境的轻量模型：

- `qwen/Qwen2.5-0.5B-Instruct`
- `qwen/Qwen2.5-1.5B-Instruct`

```bash
bash run_tests.sh
```

如需把课程推荐的大模型体验也纳入同一轮测试：

```bash
RUN_LARGE_MODELS=1 bash run_tests.sh
```

注意：`ZhipuAI/chatglm3-6b` 在免费 CPU Notebook 上可能运行很慢，建议资源充足时再开启。

## 常用参数

```bash
QUESTIONS_FILE=prompts/semantic_understanding.json bash run_tests.sh
MAX_NEW_TOKENS=128 bash run_tests.sh
MODELSCOPE_CACHE_DIR=/mnt/workspace/.cache/modelscope bash run_tests.sh
```

可查看脚本帮助：

```bash
bash run_tests.sh --help
```

## 输出位置

每个模型的测试结果会保存到：

```text
outputs/<label>/results.md
outputs/<label>/results.json
```

默认问题集位于：

```text
prompts/semantic_understanding.json
```

实验文档和报告内容见：

```text
report.md
```
