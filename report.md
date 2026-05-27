# 大语言模型部署体验与横向对比实验报告

## 一、项目说明

本项目用于课程第 3 次作业：在 ModelScope Notebook 环境中完成大语言模型部署体验、中文语义理解问答测试和模型横向对比。公开仓库用于保存实验脚本、测试问题、运行结果和报告内容。

项目不提供长期在线推理服务。ModelScope 免费 Notebook 实例存在运行时长和资源限制，更适合作为模型部署和短时测试环境。

## 二、实验环境

| 项目 | 内容 |
| --- | --- |
| 平台 | ModelScope Notebook |
| 推荐镜像 | ubuntu22.04-py311-torch2.3.1-1.37.1 |
| Python | 3.11 |
| PyTorch | 2.3.1 |
| 主要依赖 | modelscope、transformers、accelerate、sentencepiece、tiktoken、einops |
| 运行方式 | CPU 推理 |

## 三、部署流程

在 ModelScope Notebook 的 Terminal 中执行：

```bash
cd /mnt/workspace
git clone https://github.com/Metahumanz/ModelScopeDeployment.git
cd ModelScopeDeployment
bash setup_modelscope.sh
```

`setup_modelscope.sh` 会完成以下步骤：

1. 输出 Python 版本。
2. 输出 pip 版本。
3. 升级 pip、setuptools、wheel。
4. 安装 `requirements.txt` 中的项目依赖。

## 四、统一测试入口

所有模型问答测试统一通过根目录脚本运行：

```bash
bash run_tests.sh
```

默认会运行两个适合 CPU 环境的轻量模型：

| 模型 | 参数规模 | 选择原因 |
| --- | ---: | --- |
| Qwen2.5-0.5B-Instruct | 0.5B | 下载和推理成本低，适合先完成部署验证 |
| Qwen2.5-1.5B-Instruct | 1.5B | 中文能力通常更稳定，仍可在 CPU 环境中尝试 |

如需将 7B/8B 模型体验纳入对比，可单独运行：

```bash
bash run_deepseek7b.sh
bash run_internlm7b.sh
bash run_llama31_8b.sh
```

这些脚本每次只运行一个大模型：

| 模型 | 参数规模 | 说明 |
| --- | ---: | --- |
| DeepSeek LLM 7B Chat | 7B | DeepSeek 旧版聊天模型，不是 R1 推理模型 |
| InternLM2.5 7B Chat | 7B | 中文能力较强，适合作为国产 7B 对比模型 |
| Meta Llama 3.1 8B Instruct | 8B | 英文和多语能力较强，适合观察跨语种模型表现 |

## 五、测试问题

默认问题集位于：

```text
prompts/semantic_understanding.json
```

当前问题主要覆盖：

- 中文歧义理解。
- 双关与语义反转。
- 多层嵌套指代。
- 人物指代关系。
- 词义消歧和语用理解。

问题示例：

```text
请说出以下两句话区别在哪里？
1、冬天：能穿多少穿多少。
2、夏天：能穿多少穿多少。
```

## 六、输出结果

运行 `bash run_tests.sh` 后，每个模型会生成独立结果目录：

```text
results/<label>/results.md
results/<label>/results.json
```

默认标签包括：

| 标签 | 模型 |
| --- | --- |
| `qwen2.5-0.5b` | `qwen/Qwen2.5-0.5B-Instruct` |
| `qwen2.5-1.5b` | `qwen/Qwen2.5-1.5B-Instruct` |
| `deepseek-llm-7b-chat` | `deepseek-ai/deepseek-llm-7b-chat` |
| `internlm2.5-7b-chat` | `Shanghai_AI_Laboratory/internlm2_5-7b-chat` |
| `llama3.1-8b-instruct` | `LLM-Research/Meta-Llama-3.1-8B-Instruct` |

## 七、横向对比记录表

完成测试后，可按下表整理结果：

| 维度 | Qwen2.5-0.5B-Instruct | Qwen2.5-1.5B-Instruct | DeepSeek / InternLM / Llama |
| --- | --- | --- | --- |
| 部署难度 | 待填写 | 待填写 | 待填写 |
| CPU 推理速度 | 待填写 | 待填写 | 待填写 |
| 中文歧义理解 | 待填写 | 待填写 | 待填写 |
| 指代关系分析 | 待填写 | 待填写 | 待填写 |
| 词义消歧能力 | 待填写 | 待填写 | 待填写 |
| 回答完整性 | 待填写 | 待填写 | 待填写 |
| 稳定性 | 待填写 | 待填写 | 待填写 |
| 综合评价 | 待填写 | 待填写 | 待填写 |

分析时可重点观察：

- 模型是否能识别同一句式在不同语境中的含义差异。
- 模型是否能拆解多层嵌套指代。
- 模型是否能解释“意思”等多义词在对话中的不同语用含义。
- 回答是否稳定、是否出现明显跑题、重复或编造。
- 在 CPU 环境中的部署成本和运行耗时是否可接受。

## 八、实验结论模板

综合部署成本、运行速度和中文语义理解能力，可以从以下角度撰写结论：

- Qwen2.5-0.5B-Instruct 更适合免费 CPU 环境快速跑通部署流程。
- Qwen2.5-1.5B-Instruct 通常能提供更完整的中文解释，适合作为轻量横向对比主力模型。
- DeepSeek LLM 7B Chat、InternLM2.5 7B Chat 和 Llama 3.1 8B Instruct 下载和推理成本更高，适合作为资源允许时的补充测试。

最终报告中需要补充公开仓库链接，并根据 `results/` 中的输出结果填写对比分析。
