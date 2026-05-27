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

`setup_modelscope.sh` 用于检查环境并安装依赖。`run_tests.sh` 会依次运行默认模型测试，并把结果保存到 `results/`。

## 默认测试

默认运行两个适合 CPU 环境的模型：

- `qwen/Qwen2.5-0.5B-Instruct`
- `qwen/Qwen2.5-1.5B-Instruct`

如需单独测试 7B/8B 模型：

```bash
bash run_deepseek7b.sh
bash run_internlm7b.sh
bash run_llama31_8b.sh
```

这些模型下载体积和内存占用都明显更高，建议资源充足时一次只运行一个。

## 常用参数

```bash
QUESTIONS_FILE=prompts/semantic_understanding.json bash run_tests.sh
MAX_NEW_TOKENS=128 bash run_tests.sh
MAX_NEW_TOKENS=128 bash run_deepseek7b.sh
TORCH_DTYPE=bfloat16 bash run_internlm7b.sh
MODELSCOPE_CACHE_DIR=/mnt/workspace/.cache/modelscope bash run_tests.sh
```

可查看脚本帮助：

```bash
bash run_tests.sh --help
bash run_deepseek7b.sh --help
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
