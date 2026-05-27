# 大语言模型部署体验与横向对比实验

公开仓库：[Metahumanz/ModelScopeDeployment](https://github.com/Metahumanz/ModelScopeDeployment)

## 使用方法

在 ModelScope Notebook 的 Terminal 中执行：

```bash
cd /mnt/workspace
git clone https://github.com/Metahumanz/ModelScopeDeployment.git
cd ModelScopeDeployment
bash setup_modelscope.sh
bash run_tests.sh
```

`setup_modelscope.sh` 用于检查环境并安装依赖。`run_tests.sh` 会依次运行多个小模型测试，并把结果保存到 `results/`。

## 默认测试

默认运行 5 个适合 CPU 环境的小模型：

- `qwen/Qwen2.5-0.5B-Instruct`
- `qwen/Qwen2-0.5B-Instruct`
- `qwen/Qwen1.5-0.5B-Chat`
- `qwen/Qwen2.5-1.5B-Instruct`
- `Shanghai_AI_Laboratory/internlm2-chat-1_8b-sft`

默认每题最多生成 32 个 token，使用 `float32` 在 CPU 上加载模型，并边生成边打印答案。

```bash
MAX_NEW_TOKENS=32 bash run_tests.sh
```

## 常用参数

```bash
QUESTIONS_FILE=prompts/semantic_understanding.json bash run_tests.sh
MAX_NEW_TOKENS=32 bash run_tests.sh
TORCH_DTYPE=float32 bash run_tests.sh
TORCH_NUM_THREADS=4 bash run_tests.sh
MODELSCOPE_CACHE_DIR=/mnt/workspace/.cache/modelscope bash run_tests.sh
```

可查看脚本帮助：

```bash
bash run_tests.sh --help
```

## 输出位置

每个模型的测试结果会保存到：

```text
results/<label>/results.md
results/<label>/results.json
```

默认问题集位于：

```text
prompts/semantic_understanding.json
```

实验说明和报告内容见：

```text
report.md
```
