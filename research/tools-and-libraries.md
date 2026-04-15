# Tools and Libraries

Open source tools for cost tracking, routing, compression, and inference optimization.

## Cost Tracking & Observability

| Tool | Stars | Description | Link |
|------|-------|-------------|------|
| Langfuse | 24K | Open-source LLM observability + cost tracking | [GitHub](https://github.com/langfuse/langfuse) |
| Helicone | 5.4K | LLM observability, 300+ models, SOC 2 | [GitHub](https://github.com/Helicone/helicone) |
| LiteLLM | 41K | SDK + proxy for 100+ LLMs with cost tracking | [GitHub](https://github.com/BerriAI/litellm) |
| tokencost | 2K | USD cost estimates for 400+ LLMs | [GitHub](https://github.com/AgentOps-AI/tokencost) |
| AgentOps | 5.4K | Agent monitoring with LLM cost tracking | [GitHub](https://github.com/AgentOps-AI/agentops) |
| Helicone AI Gateway | 559 | Fastest open-source AI gateway (Rust) | [GitHub](https://github.com/Helicone/ai-gateway) |
| tiktoken | - | OpenAI's fast BPE tokenizer, 3-6x faster | [GitHub](https://github.com/openai/tiktoken) |

### Docs

- [Langfuse cost tracking](https://langfuse.com/docs/observability/features/token-and-cost-tracking)
- [Helicone cost tracking cookbook](https://docs.helicone.ai/guides/cookbooks/cost-tracking)
- [LiteLLM spend tracking](https://docs.litellm.ai/docs/proxy/cost_tracking)
- [LiteLLM budget routing](https://docs.litellm.ai/docs/proxy/provider_budget_routing)
- [LangSmith cost tracking](https://docs.langchain.com/langsmith/cost-tracking)
- [LlamaIndex cost analysis](https://docs.llamaindex.ai/en/stable/understanding/evaluating/cost_analysis/)
- [Portkey AI Gateway](https://portkey.ai/features/ai-gateway) - 30-50% cost reduction

## Model Routing

| Tool | Stars | Description | Link |
|------|-------|-------------|------|
| RouteLLM | 4.7K | LLM router framework by LMSYS | [GitHub](https://github.com/lm-sys/RouteLLM) |
| Bifrost | 3.3K | 50x faster than LiteLLM; adaptive load balancer | [GitHub](https://github.com/maximhq/bifrost) |
| NotDiamond | - | Per-query best-model selection | [GitHub](https://github.com/Not-Diamond/notdiamond-python) |
| NotDiamond RoRF | - | Random forest-based LLM router | [GitHub](https://github.com/Not-Diamond/RoRF) |

### Services

- [OpenRouter](https://openrouter.ai/docs/quickstart) - 300+ models, [auto-router](https://openrouter.ai/docs/guides/routing/routers/auto-router)
- [Martian Router](https://route.withmartian.com/) - 20-97% cost reduction via Model Mapping

## Prompt Compression

| Tool | Stars | Description | Link |
|------|-------|-------------|------|
| LLMLingua | 6K | Up to 20x compression (Microsoft) | [GitHub](https://github.com/microsoft/LLMLingua) |
| Headroom | - | Type-aware routing to specialized compressors | [GitHub](https://github.com/chopratejas/headroom) |
| code2prompt | 7.3K | Codebase to LLM prompt with token counting | [GitHub](https://github.com/mufeedvh/code2prompt) |

## Inference Engines

| Tool | Stars | Description | Link |
|------|-------|-------------|------|
| vLLM | 74.6K | PagedAttention, high-throughput inference | [GitHub](https://github.com/vllm-project/vllm) |
| SGLang | 25.2K | RadixAttention for KV cache reuse | [GitHub](https://github.com/sgl-project/sglang) |
| GPUStack | 4.7K | GPU cluster manager for vLLM/SGLang | [GitHub](https://github.com/gpustack/gpustack) |

### Docs

- [vLLM optimization guide](https://docs.vllm.ai/en/stable/configuration/optimization/)
- [vLLM v0.6.0: 2.7x throughput](https://blog.vllm.ai/2024/09/05/perf-update.html)
- [SGLang docs](https://sgl-project.github.io/) - 5x faster with RadixAttention
- [DSPy optimization](https://dspy.ai/learn/optimization/overview/) - Programmatic prompt optimization

## KV Cache & Compression

| Tool | Stars | Description | Link |
|------|-------|-------------|------|
| NVIDIA kvpress | 997 | KV cache compression made easy | [GitHub](https://github.com/NVIDIA/kvpress) |
| R-KV | 1.2K | Redundancy-aware KV cache compression | [GitHub](https://github.com/Zefan-Cai/R-KV) |
| llm-compressor | 2.9K | Compression for vLLM deployment | [GitHub](https://github.com/vllm-project/llm-compressor) |
| NVIDIA Model Optimizer | 2.3K | Quantization, pruning, distillation | [GitHub](https://github.com/NVIDIA/Model-Optimizer) |
| TurboQuant | 536 | 5x KV cache compression (ICLR 2026) | [GitHub](https://github.com/tonbistudio/turboquant-pytorch) |
| aibrix | 4.7K | Cost-efficient GenAI infrastructure | [GitHub](https://github.com/vllm-project/aibrix) |

## Browser Tools (Token Efficiency)

| Tool | Output Size | Description | Link |
|------|-----------|-------------|------|
| WebFetch | ~1.5KB | AI-summarized, 20x more efficient | [Docs](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-fetch-tool) |
| Playwright MCP | ~33KB | Accessibility tree snapshots | [GitHub](https://github.com/microsoft/playwright-mcp) |
| Agent Browser | ~28KB | Rust CLI, full Chromium | [GitHub](https://github.com/vercel-labs/agent-browser) |
| Lightpanda | ~16KB | Zig browser, 1.8s/page | [GitHub](https://github.com/lightpanda-io/browser) |
| browser-use | - | Foundation library for AI browser agents | [GitHub](https://github.com/browser-use/browser-use) |

## Curated Lists

- [Awesome KV Cache Compression](https://github.com/October2001/Awesome-KV-Cache-Compression) - Papers on KV cache
- [Awesome LLM Compression](https://github.com/HuangOwen/Awesome-LLM-Compression) - LLM compression research
- [Awesome AI Model Routing](https://github.com/Not-Diamond/awesome-ai-model-routing) - Routing approaches
- [Context Engineering Guide](https://github.com/mlnjsh/context-engineering) - Context optimization

## Pricing Comparison Tools

- [Price Per Token](https://pricepertoken.com/) - 300+ models, daily updated
- [Artificial Analysis Calculator](https://artificialanalysis.ai/tools/llm-price-calculator) - 100+ models
- [Artificial Analysis Leaderboard](https://artificialanalysis.ai/leaderboards/models) - Quality + price + speed
- [Simon Willison's LLM Prices](https://tools.simonwillison.net/llm-prices) - Interactive calculator
- [Helicone Cost Comparison](https://www.helicone.ai/llm-cost) - 300+ model calculator
- [CostGoat](https://costgoat.com/compare/llm-api) - 302+ APIs
- [Langtail](https://langtail.com/llm-price-comparison) - Side-by-side
- [WhatLLM](https://whatllm.org/) - 256 models, 43+ providers
