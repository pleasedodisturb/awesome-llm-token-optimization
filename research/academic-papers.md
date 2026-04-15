# Academic Papers on Token Optimization

52 papers across 8 categories, sourced from arxiv. Prioritizes 2023-2026.

## 1. Prompt Compression (10 papers)

| # | Title | Year | Key Result | Link |
|---|-------|------|-----------|------|
| 1 | Prompt Compression for Large Language Models: A Survey | 2024 | Comprehensive survey of all techniques | [arxiv](https://arxiv.org/abs/2410.12388) |
| 2 | LLMLingua: Compressing Prompts for Accelerated Inference | 2023 | Up to 20x compression, 1.5pt drop (EMNLP) | [arxiv](https://arxiv.org/abs/2310.05736) |
| 3 | LongLLMLingua: Accelerating LLMs in Long Context Scenarios | 2023 | 21.4% performance boost with 4x fewer tokens | [arxiv](https://arxiv.org/abs/2310.06839) |
| 4 | LLMLingua-2: Data Distillation for Task-Agnostic Compression | 2024 | 3-6x faster than v1; BERT distillation (ACL) | [arxiv](https://arxiv.org/abs/2403.12968) |
| 5 | Selective Context: Compressing Context for Inference Efficiency | 2023 | Self-information pruning; 50% reduction, 36% memory savings | [arxiv](https://arxiv.org/abs/2310.06201) |
| 6 | RECOMP: Improving RAG LMs with Compression | 2023 | Extractive + abstractive; 5% token ratio | [arxiv](https://arxiv.org/abs/2310.04408) |
| 7 | 500xCompressor: Generalized Prompt Compression | 2024 | Contexts down to single token (6-480x ratios) | [arxiv](https://arxiv.org/abs/2408.03094) |
| 8 | SCOPE: Generative Approach for LLM Prompt Compression | 2025 | Training-free, no LLM calls needed | [arxiv](https://arxiv.org/abs/2508.15813) |
| 9 | Empirical Study on Prompt Compression for LLMs | 2025 | Benchmarks 6 methods across 13 datasets | [arxiv](https://arxiv.org/abs/2505.00019) |
| 10 | Dynamic Compressing Prompts for Efficient Inference | 2025 | MDP-based adaptive token removal | [arxiv](https://arxiv.org/abs/2504.11004) |

## 2. Context Window Optimization (7 papers)

| # | Title | Year | Key Result | Link |
|---|-------|------|-----------|------|
| 11 | Lost in the Middle: How Language Models Use Long Contexts | 2023 | Models struggle with mid-context info (seminal) | [arxiv](https://arxiv.org/abs/2307.03172) |
| 12 | YaRN: Efficient Context Window Extension | 2023 | 10x less tokens for context extension | [arxiv](https://arxiv.org/abs/2309.00071) |
| 13 | Beyond the Limits: Survey of Context Extension Techniques | 2024 | Survey of all techniques | [arxiv](https://arxiv.org/abs/2402.02244) |
| 14 | InfiniteICL: Breaking the Context Window Size Limit | 2025 | 90% context reduction, 103% of full-context performance | [arxiv](https://arxiv.org/abs/2504.01707) |
| 15 | SkyLadder: Context Window Scheduling for Pretraining | 2025 | 22% training time savings | [arxiv](https://arxiv.org/abs/2503.15450) |
| 16 | RAG or Long-Context LLMs? Comprehensive Study and Hybrid | 2024 | Self-Route hybrid method | [arxiv](https://arxiv.org/abs/2407.16833) |
| 17 | Long Context vs. RAG: Evaluation and Revisits | 2025 | RAG wins for dialogue, long-context wins for QA | [arxiv](https://arxiv.org/abs/2501.01880) |

## 3. Token Cost / Efficiency (6 papers)

| # | Title | Year | Key Result | Link |
|---|-------|------|-----------|------|
| 18 | TRIM: Token Reduction and Inference Modeling | 2024 | 19.4% token savings on GPT-4o | [arxiv](https://arxiv.org/abs/2412.07682) |
| 19 | Mirror Speculative Decoding | 2025 | Breaks serial barrier via parallel spec decoding | [arxiv](https://arxiv.org/abs/2510.13161) |
| 20 | LongSpec: Long-Context Lossless Speculative Decoding | 2025 | Constant memory regardless of context length | [arxiv](https://arxiv.org/abs/2502.17421) |
| 21 | Reward-Guided Speculative Decoding | 2025 | Reward models guide speculative decoding | [arxiv](https://arxiv.org/abs/2501.19324) |
| 22 | LazyLLM: Dynamic Token Pruning for Long Context | 2024 | Lazily computes only important tokens from prefill | [arxiv](https://arxiv.org/abs/2407.14057) |
| 23 | SlimInfer: Dynamic Token Pruning | 2025 | 1.88x latency reduction on RTX 4090 | [arxiv](https://arxiv.org/abs/2508.06447) |

## 4. Model Routing / Cascading (6 papers)

| # | Title | Year | Key Result | Link |
|---|-------|------|-----------|------|
| 24 | FrugalGPT: Reducing Cost While Improving Performance | 2023 | Seminal cascade paper; up to 98% cost reduction | [arxiv](https://arxiv.org/abs/2305.05176) |
| 25 | RouteLLM: Learning to Route with Preference Data | 2024 | 2x+ cost reduction without quality loss | [arxiv](https://arxiv.org/abs/2406.18665) |
| 26 | Hybrid LLM: Cost-Efficient Query Routing | 2024 | 40% fewer calls to large model | [arxiv](https://arxiv.org/abs/2404.14618) |
| 27 | Unified Approach to Routing and Cascading | 2024 | +14% over individual strategies | [arxiv](https://arxiv.org/abs/2410.10347) |
| 28 | Dynamic Model Routing and Cascading Survey | 2026 | Comprehensive survey | [arxiv](https://arxiv.org/abs/2603.04445) |
| 29 | Pay for Hints, Not Answers: LLM Shepherding | 2026 | Small model gets hints from large model | [arxiv](https://arxiv.org/abs/2601.22132) |

## 5. Caching for LLMs (6 papers)

| # | Title | Year | Key Result | Link |
|---|-------|------|-----------|------|
| 30 | PagedAttention (vLLM) | 2023 | Near-zero waste in KV cache via paging | [arxiv](https://arxiv.org/abs/2309.06180) |
| 31 | SGLang: RadixAttention | 2023 | Automatic KV cache reuse via radix tree | [arxiv](https://arxiv.org/abs/2312.07104) |
| 32 | VectorQ: Adaptive Semantic Prompt Caching | 2025 | Up to 100x latency reduction | [arxiv](https://arxiv.org/abs/2502.03771) |
| 33 | KV-Compress: Variable Rate KV Cache Compression | 2024 | PagedAttention compatible | [arxiv](https://arxiv.org/abs/2410.00161) |
| 34 | vAttention: Dynamic Memory Without PagedAttention | 2024 | 1.99x throughput over vLLM | [arxiv](https://arxiv.org/abs/2405.04437) |
| 35 | KV Cache Optimization Survey | 2026 | Comprehensive techniques survey | [arxiv](https://arxiv.org/abs/2603.20397) |

## 6. Tokenization Research (4 papers)

| # | Title | Year | Key Result | Link |
|---|-------|------|-----------|------|
| 36 | MUTANT: Multilingual Tokenizer Design | 2025 | PickyBPE, Scaffold-BPE, SuperBPE | [arxiv](https://arxiv.org/abs/2511.03237) |
| 37 | Art of Breaking Words: Multilingual Tokenizer Design | 2025 | Token-to-word ratio = inference speed | [arxiv](https://arxiv.org/abs/2508.06533) |
| 38 | Crosslingual Tokenizer Inequities | 2025 | BPE has best compression; byte premiums analyzed | [arxiv](https://arxiv.org/abs/2510.21909) |
| 39 | Teaching Old Tokenizers New Words | 2025 | Efficient vocabulary extension for new domains | [arxiv](https://arxiv.org/abs/2512.03989) |

## 7. Prompt Engineering for Efficiency (5 papers)

| # | Title | Year | Key Result | Link |
|---|-------|------|-----------|------|
| 40 | APE: LLMs Are Human-Level Prompt Engineers | 2022 | Outperformed humans on 19/24 tasks | [arxiv](https://arxiv.org/abs/2211.01910) |
| 41 | OPRO: LLMs as Optimizers | 2023 | 50% improvement over human prompts on BBH | [arxiv](https://arxiv.org/abs/2309.03409) |
| 42 | DSPy: Compiling Declarative LM Calls | 2023 | Replaces manual prompting with auto optimizers | [arxiv](https://arxiv.org/abs/2310.03714) |
| 43 | Concise Chain-of-Thought (CCoT) | 2024 | 48.7% shorter responses; 22.67% cost savings | [arxiv](https://arxiv.org/abs/2401.05618) |
| 44 | Chain of Draft: Thinking Faster by Writing Less | 2025 | 7.6% of CoT tokens, matches accuracy | [arxiv](https://arxiv.org/abs/2502.18600) |

## 8. Quantization and Inference Optimization (8 papers)

| # | Title | Year | Key Result | Link |
|---|-------|------|-----------|------|
| 45 | GPTQ: Post-Training Quantization for GPT | 2022 | 175B params in 4hrs; 2-4x speedup | [arxiv](https://arxiv.org/abs/2210.17323) |
| 46 | AWQ: Activation-aware Weight Quantization | 2023 | 3x+ speedup via TinyChat | [arxiv](https://arxiv.org/abs/2306.00978) |
| 47 | Mixture of Experts in LLMs (Survey) | 2025 | MoE efficiency, scaling, sparse activation | [arxiv](https://arxiv.org/abs/2507.11181) |
| 48 | Mixture Compressor for MoE LLMs | 2024 | 76.6% compression at 2.54 bits, 3.8% accuracy loss | [arxiv](https://arxiv.org/abs/2410.06270) |
| 49 | MoSE: Mixture of Slimmable Experts | 2026 | Width-based conditional computation | [arxiv](https://arxiv.org/abs/2602.06154) |
| 50 | Comprehensive Evaluation of Quantized LLMs | 2024 | GPTQ vs AWQ across models up to 405B | [arxiv](https://arxiv.org/abs/2409.11055) |
| 51 | Inference Economics of Language Models | 2025 | Theoretical cost-per-token vs speed tradeoffs | [arxiv](https://arxiv.org/abs/2506.04645) |
| 52 | OckBench: Measuring Efficiency of LLM Reasoning | 2025 | Billing by token penalizes efficient reasoning | [arxiv](https://arxiv.org/abs/2511.05722) |

## Summary by Year

- **2022:** 2 papers (GPTQ, APE -- foundational)
- **2023:** 11 papers (LLMLingua family, FrugalGPT, PagedAttention, SGLang, OPRO, DSPy)
- **2024:** 14 papers (LLMLingua-2, RAG comparisons, RouteLLM, quantization benchmarks)
- **2025:** 19 papers (Chain of Draft, InfiniteICL, speculative decoding, tokenizer research)
- **2026:** 6 papers (routing surveys, MoSE, KV cache survey)

## Highest Impact for Practical Cost Reduction

1. **Chain of Draft** -- 7.6% token usage for reasoning
2. **FrugalGPT** -- 98% cost reduction via cascading
3. **LLMLingua-2** -- Task-agnostic compression
4. **PagedAttention/vLLM** -- Near-zero KV cache waste
5. **RouteLLM** -- 2x+ cost reduction via routing
