# Awesome LLM Token Optimization [![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

> A curated list of strategies, tools, papers, and resources for reducing LLM token costs and improving efficiency in production.

Building with LLMs is expensive. An agent processing 10 reasoning steps can consume 50K-100K tokens per task. This list collects everything you need to cut costs by 80-99% without sacrificing quality.

## Contents

- [Quick Wins](#quick-wins)
- [Prompt Caching](#prompt-caching)
- [Batch APIs](#batch-apis)
- [Model Routing](#model-routing)
- [Prompt Compression](#prompt-compression)
- [Context Window Management](#context-window-management)
- [KV Cache Optimization](#kv-cache-optimization)
- [Browser Tool Efficiency](#browser-tool-efficiency)
- [Cost Tracking Tools](#cost-tracking-tools)
- [Pricing Comparison](#pricing-comparison)
- [Prompt Engineering for Efficiency](#prompt-engineering-for-efficiency)
- [Comprehensive Guides](#comprehensive-guides)
- [Academic Papers](#academic-papers)
- [Community Resources](#community-resources)

---

## Quick Wins

The highest-impact strategies ranked by effort-to-savings ratio:

| Strategy | Savings | Effort | Link |
|----------|---------|--------|------|
| Prompt caching | 90% input tokens | Add cache headers | [Anthropic](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching) |
| Token-efficient tool use | 70% output reduction | Flip a flag | [Anthropic](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/token-efficient-tool-use) |
| Batch API | 50% | Queue non-urgent work | [Anthropic](https://docs.anthropic.com/en/api/creating-message-batches) |
| Model routing | 60-95% | Route by task complexity | [RouteLLM](https://github.com/lm-sys/RouteLLM) |
| Response caching | 100% on repeats | Add a cache layer | [Redis guide](https://redis.io/blog/llm-token-optimization-speed-up-apps/) |
| Prompt compression | 5-20x | Use LLMLingua | [GitHub](https://github.com/microsoft/LLMLingua) |

**Combined pipeline:** Cache prefix (90%) + route to cheapest model (60-95%) + batch non-urgent (50%) + compress prompts (5-20x) + cache responses (100% on repeats) = **95-99% cost reduction** vs. naive approach.

## Prompt Caching

Reuse previously-processed prompt prefixes to avoid re-computing the same tokens.

### Provider Docs

- [Anthropic Prompt Caching](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching) - 90% discount, 5min/1hr TTL, min 1,024 tokens.
- [Anthropic Caching Announcement](https://www.anthropic.com/news/prompt-caching) - Blog post explaining economics.
- [Anthropic Token-Saving Updates](https://www.anthropic.com/news/token-saving-updates) - Cache-aware rate limits, simplified caching.
- [Anthropic Extended Thinking + Caching](https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking) - Thinking blocks get cached in tool-use loops.
- [OpenAI Prompt Caching](https://platform.openai.com/docs/guides/prompt-caching) - 50% discount, automatic for 1024+ token prompts.
- [OpenAI Prompt Caching Cookbook](https://developers.openai.com/cookbook/examples/prompt_caching_201) - Advanced techniques with code.
- [Google Gemini Context Caching](https://ai.google.dev/gemini-api/docs/caching) - Implicit (auto) and explicit caching, 90% discount.
- [Google Vertex AI Caching](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/context-cache/context-cache-overview) - Enterprise context caching.
- [DeepSeek KV Cache](https://api-docs.deepseek.com/guides/kv_cache) - Disk-based, 64-token granularity, 90% savings.

### Strategy: Cached Prefix Pattern

Structure prompts so the system prompt + user profile is the first ~2,000 tokens. All subsequent calls share this prefix. For bulk operations (e.g., scoring 50 items): 1x full + 49x at 10% = **88% total savings**.

## Batch APIs

50% discounts for non-time-critical requests. Combine with caching for 95% savings.

- [Anthropic Message Batches](https://docs.anthropic.com/en/api/creating-message-batches) - Up to 10,000 requests, 24hr turnaround.
- [Anthropic Batches Announcement](https://www.anthropic.com/news/message-batches-api) - Use cases and GA details.
- [OpenAI Batch API](https://platform.openai.com/docs/guides/batch) - 50% discount, 50K requests per file.
- [OpenAI Batch API FAQ](https://help.openai.com/en/articles/9197833-batch-api-faq) - Limits and behavior.
- [Google Gemini Batch API](https://ai.google.dev/gemini-api/docs/batch-api) - 50% discount, combinable with context caching.
- [Google Vertex Batch Prediction](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/batch-prediction-gemini) - Enterprise batch.

## Model Routing

Route simple tasks to cheaper models. 80% of typical LLM calls don't need the most expensive model.

### Frameworks

- [RouteLLM](https://github.com/lm-sys/RouteLLM) - Open-source LLM router by LMSYS. Trains routers from preference data; 2x+ cost reduction. ![Stars](https://img.shields.io/github/stars/lm-sys/RouteLLM)
- [LiteLLM](https://github.com/BerriAI/litellm) - SDK + proxy for 100+ LLMs with routing, cost tracking. Strategies: least-busy, cost-based, latency-based. ![Stars](https://img.shields.io/github/stars/BerriAI/litellm)
- [NotDiamond](https://github.com/Not-Diamond/notdiamond-python) - Per-query best-model selection. ![Stars](https://img.shields.io/github/stars/Not-Diamond/notdiamond-python)
- [Bifrost](https://github.com/maximhq/bifrost) - 50x faster than LiteLLM; adaptive load balancer, 1000+ models. ![Stars](https://img.shields.io/github/stars/maximhq/bifrost)
- [vLLM Semantic Router](https://github.com/vllm-project/semantic-router) - System-level signal-driven router for Mixture-of-Models across cloud, data center, and edge. v0.2 "Athena" (March 2026). ![Stars](https://img.shields.io/github/stars/vllm-project/semantic-router)
- [OpenRouter](https://openrouter.ai/docs/quickstart) - Unified API for 300+ models with [auto-router](https://openrouter.ai/docs/guides/routing/routers/auto-router).
- [Martian Router](https://route.withmartian.com/) - Patent-pending; cuts costs 20-97% via "Model Mapping".

### Curated Lists

- [Awesome AI Model Routing](https://github.com/Not-Diamond/awesome-ai-model-routing) - Comprehensive list of routing approaches.

### Research

- [RouteLLM paper](https://www.lmsys.org/blog/2024-07-01-routellm/) - LMSYS blog on cost-quality tradeoffs.
- [Cascade Routing](https://arxiv.org/abs/2410.10347) - Combined routing + cascading; +14% over individual strategies.
- [Dynamic Routing Survey (2026)](https://arxiv.org/abs/2603.04445) - Comprehensive survey.
- [IBM LLM Routers](https://research.ibm.com/blog/LLM-routers) - IBM's research on training routers.
- [LLM Routing Explained](https://towardsdatascience.com/llm-routing-intuitively-and-exhaustively-explained-5b0789fe27aa/) - Intuitive guide.
- [vLLM Semantic Router paper](https://arxiv.org/abs/2603.04444) - Signal-driven decision routing for Mixture-of-Modality models; composable signal orchestration across heuristic and neural classifiers.

## Prompt Compression

Reduce prompt size while preserving information quality.

### Tools

- [LLMLingua](https://github.com/microsoft/LLMLingua) - Up to 20x compression. Coarse-to-fine iterative method. Integrates with LangChain/LlamaIndex. ![Stars](https://img.shields.io/github/stars/microsoft/LLMLingua)
- [Headroom](https://github.com/chopratejas/headroom) - Routes JSON/code/text to specialized compressors.
- [code2prompt](https://github.com/mufeedvh/code2prompt) - Codebase to LLM prompt with token counting. ![Stars](https://img.shields.io/github/stars/mufeedvh/code2prompt)

### Research

- [LLMLingua paper (EMNLP'23)](https://arxiv.org/abs/2310.05736) - Budget controller + token-level iterative compression.
- [LLMLingua-2 (ACL'24)](https://arxiv.org/abs/2403.12968) - BERT encoder via GPT-4 distillation; 3-6x faster.
- [LongLLMLingua](https://arxiv.org/abs/2310.06839) - Long context extension; 21.4% boost with 4x fewer tokens.
- [Selective Context](https://arxiv.org/abs/2310.06201) - Self-information pruning; 50% context reduction.
- [RECOMP](https://arxiv.org/abs/2310.04408) - Extractive + abstractive compressors; 5% token ratio.
- [500xCompressor](https://arxiv.org/abs/2408.03094) - Extreme: contexts down to a single token (6-480x ratios).
- [LoPace](https://arxiv.org/abs/2602.13266) - Lossless; 72.2% savings with 100% reconstruction.
- [SCOPE](https://arxiv.org/abs/2508.15813) - Training-free generative rewriting.
- [Prompt Compression Survey](https://arxiv.org/abs/2410.12388) - Comprehensive survey of all techniques.
- [CompactPrompt](https://arxiv.org/abs/2510.18043) - Unified prompt + data compression pipeline.
- [Efficient Prompting Survey](https://arxiv.org/abs/2404.01077) - Survey of efficient prompting methods.

### Guides

- [LLMLingua Research Blog](https://www.microsoft.com/en-us/research/blog/llmlingua-innovating-llm-efficiency-with-prompt-compression/) - Microsoft Research deep dive.
- [Prompt Compression Tutorial (FreeCodeCamp)](https://www.freecodecamp.org/news/how-to-compress-your-prompts-and-reduce-llm-costs/) - Practical guide with code.
- [Prompt Compression Overview (MLM)](https://machinelearningmastery.com/prompt-compression-for-llm-generation-optimization-and-cost-reduction/) - 6x to 480x compression ratios.
- [Awesome LLM Compression](https://github.com/HuangOwen/Awesome-LLM-Compression) - Curated paper list.

### Lossless Compression Principles

Rule-based lossless distillation achieves **3-4:1 compression** without any model:

- **Strip:** prose transitions, hedging, rhetoric, common knowledge
- **Preserve:** numbers, entities, decisions, constraints, risks
- **Transform:** prose to dense bullets; verbose to semicolon-joined
- **Split:** 3,000-5,000 token self-contained sections, loadable independently

## Context Window Management

### Key Research

- [Context Rot (Chroma)](https://research.trychroma.com/context-rot) - LLMs degrade well before context limits; tested 18 models. [GitHub toolkit](https://github.com/chroma-core/context-rot).
- [Lost in the Middle](https://arxiv.org/abs/2307.03172) - Seminal 2023 finding: models struggle with info in the middle.
- [RAG vs Long Context](https://arxiv.org/abs/2501.01880) - RAG wins for dialogue-based queries; long context wins for QA.
- [RAG vs Long Context (Elastic)](https://www.elastic.co/search-labs/blog/rag-vs-long-context-model-llm) - RAG is 1250x cheaper for many queries.
- [Long Context RAG (Databricks)](https://www.databricks.com/blog/long-context-rag-performance-llms) - Degradation after 32K-64K tokens.
- [Self-Route Hybrid (2024)](https://arxiv.org/abs/2407.16833) - Proposes combining RAG and long context adaptively.
- [InfiniteICL](https://arxiv.org/abs/2504.01707) - 90% context reduction, 103% of full-context performance.
- [Context Extension Survey](https://arxiv.org/abs/2402.02244) - All context extension techniques surveyed.

### Provider Docs

- [Anthropic Long Context Tips](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips) - Place docs at top, use XML tags.
- [Anthropic Context Windows](https://docs.anthropic.com/en/docs/build-with-claude/context-windows) - How context works, server-side compaction.
- [Anthropic Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) - Finding the smallest high-signal token set.
- [Anthropic Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Managing context across extended workflows.

### Chunking & Splitting

- [Pinecone Chunking Guide](https://www.pinecone.io/learn/chunking-strategies/) - Fixed-length, semantic, hierarchical.
- [Advanced Chunking (Galileo)](https://galileo.ai/blog/mastering-rag-advanced-chunking-techniques-for-llm-applications) - Agentic and LLM-based.
- [Context Engineering Guide](https://github.com/mlnjsh/context-engineering) - Curated papers and tools.
- [Efficient Context Management (JetBrains)](https://blog.jetbrains.com/research/2025/12/efficient-context-management/) - Observation masking vs summarization.

## KV Cache Optimization

Server-side optimizations for inference efficiency.

### Inference Engines

- [vLLM](https://github.com/vllm-project/vllm) - PagedAttention, high-throughput inference. ![Stars](https://img.shields.io/github/stars/vllm-project/vllm)
- [SGLang](https://github.com/sgl-project/sglang) - RadixAttention for automatic KV cache reuse. ![Stars](https://img.shields.io/github/stars/sgl-project/sglang)
- [GPUStack](https://github.com/gpustack/gpustack) - GPU cluster manager for vLLM/SGLang. ![Stars](https://img.shields.io/github/stars/gpustack/gpustack)

### Compression Tools

- [NVIDIA kvpress](https://github.com/NVIDIA/kvpress) - KV cache compression made easy. ![Stars](https://img.shields.io/github/stars/NVIDIA/kvpress)
- [R-KV](https://github.com/Zefan-Cai/R-KV) - Redundancy-aware compression (NeurIPS 2025). ![Stars](https://img.shields.io/github/stars/Zefan-Cai/R-KV)
- [llm-compressor](https://github.com/vllm-project/llm-compressor) - Compression for deployment with vLLM. ![Stars](https://img.shields.io/github/stars/vllm-project/llm-compressor)
- [NVIDIA Model Optimizer](https://github.com/NVIDIA/Model-Optimizer) - Quantization, pruning, distillation, speculative decoding. ![Stars](https://img.shields.io/github/stars/NVIDIA/Model-Optimizer)
- [TurboQuant](https://github.com/tonbistudio/turboquant-pytorch) - Google's ICLR 2026; 5x KV cache compression.
- [aibrix](https://github.com/vllm-project/aibrix) - Cost-efficient infrastructure for GenAI inference. ![Stars](https://img.shields.io/github/stars/vllm-project/aibrix)

### Research

- [PagedAttention (vLLM)](https://arxiv.org/abs/2309.06180) - Foundational; near-zero waste in KV cache memory.
- [RadixAttention (SGLang)](https://arxiv.org/abs/2312.07104) - Automatic KV cache reuse via radix tree.
- [KV Cache Optimization Survey (2026)](https://arxiv.org/abs/2603.20397) - Comprehensive survey.
- [KV-Compress](https://arxiv.org/abs/2410.00161) - Variable-head-rate compression, PagedAttention compatible.
- [vAttention](https://arxiv.org/abs/2405.04437) - Up to 1.99x decode throughput over vLLM.
- [Semantic Prompt Caching (VectorQ)](https://arxiv.org/abs/2502.03771) - Up to 100x latency reduction.
- [Speculative Sampling](https://github.com/feifeibear/LLMSpeculativeSampling) - Fast inference via speculative decoding.
- [Awesome KV Cache Compression](https://github.com/October2001/Awesome-KV-Cache-Compression) - Must-read paper list.

### Educational

- [mini-sglang](https://github.com/sgl-project/mini-sglang) - Learn LLM serving internals.
- [tiny-llm](https://github.com/skyzh/tiny-llm) - Build a tiny vLLM on Apple Silicon.

## Browser Tool Efficiency

Different browser automation approaches consume vastly different context.

| Agent | Output Size | Efficiency | Link |
|-------|-----------|-----------|------|
| WebFetch | ~1.5 KB (AI-summarized) | **20x better** | [Docs](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-fetch-tool) |
| Playwright MCP | ~10-33 KB (accessibility tree) | Baseline | [GitHub](https://github.com/microsoft/playwright-mcp) |
| Agent Browser | ~28 KB (accessibility tree) | Similar | [GitHub](https://github.com/vercel-labs/agent-browser) |
| Lightpanda | ~16 KB (raw markdown) | 2x better | [GitHub](https://github.com/lightpanda-io/browser) |

For 10-page workflows: WebFetch = ~15KB vs Playwright = ~330KB total context consumed.

### Why Accessibility Trees Are Efficient

The [accessibility tree](https://developer.mozilla.org/en-US/docs/Glossary/Accessibility_tree) strips visual styling to retain only semantic structure (name, role, state, value). 10-50x smaller than raw HTML. See: [Token cost analysis in browser MCPs](https://dev.to/kuroko1t/how-accessibility-tree-formatting-affects-token-cost-in-browser-mcps-n2a).

### Further Reading

- [WebFetch vs WebSearch analysis](https://mikhail.io/2025/10/claude-code-web-tools/) - Deep comparison.
- [browser-use](https://github.com/browser-use/browser-use) - Foundation library for AI browser agents.
- [Chrome full accessibility tree](https://developer.chrome.com/blog/full-accessibility-tree) - DevTools feature.

## Cost Tracking Tools

- [Langfuse](https://github.com/langfuse/langfuse) - Open-source LLM observability + cost tracking. [Cost tracking docs](https://langfuse.com/docs/observability/features/token-and-cost-tracking). ![Stars](https://img.shields.io/github/stars/langfuse/langfuse)
- [Helicone](https://github.com/Helicone/helicone) - LLM observability, 300+ models, SOC 2. [Cost tracking cookbook](https://docs.helicone.ai/guides/cookbooks/cost-tracking). **Note: [Acquired by Mintlify](https://www.helicone.ai/blog/joining-mintlify) in March 2026; maintenance mode only.** ![Stars](https://img.shields.io/github/stars/Helicone/helicone)
- [LiteLLM](https://github.com/BerriAI/litellm) - SDK + proxy with [spend tracking](https://docs.litellm.ai/docs/proxy/cost_tracking) and [budget routing](https://docs.litellm.ai/docs/proxy/provider_budget_routing). ![Stars](https://img.shields.io/github/stars/BerriAI/litellm)
- [tokencost](https://github.com/AgentOps-AI/tokencost) - USD cost estimates for 400+ LLMs. ![Stars](https://img.shields.io/github/stars/AgentOps-AI/tokencost)
- [AgentOps](https://github.com/AgentOps-AI/agentops) - Agent monitoring with LLM cost tracking. ![Stars](https://img.shields.io/github/stars/AgentOps-AI/agentops)
- [Helicone AI Gateway](https://github.com/Helicone/ai-gateway) - Fastest open-source AI gateway (Rust). ![Stars](https://img.shields.io/github/stars/Helicone/ai-gateway)
- [Anthropic Token Counter](https://docs.anthropic.com/en/api/messages-count-tokens) - Free pre-flight token counting endpoint.
- [tiktoken](https://github.com/openai/tiktoken) - OpenAI's fast BPE tokenizer (Python/Rust), 3-6x faster.
- [LangSmith Cost Tracking](https://docs.langchain.com/langsmith/cost-tracking) - Automatic recording with dashboards.
- [LlamaIndex Cost Analysis](https://docs.llamaindex.ai/en/stable/understanding/evaluating/cost_analysis/) - Estimate costs before calls.

## Pricing Comparison

### Live Pricing Tools

- [Price Per Token](https://pricepertoken.com/) - Daily-updated, 300+ models.
- [Artificial Analysis Calculator](https://artificialanalysis.ai/tools/llm-price-calculator) - Free calculator, 100+ models.
- [Artificial Analysis Leaderboard](https://artificialanalysis.ai/leaderboards/models) - Quality + price + speed.
- [Simon Willison's LLM Prices](https://tools.simonwillison.net/llm-prices) - Interactive calculator.
- [Helicone LLM Cost Comparison](https://www.helicone.ai/llm-cost) - 300+ model calculator.
- [CostGoat](https://costgoat.com/compare/llm-api) - 302+ APIs from 10+ providers.
- [Langtail](https://langtail.com/llm-price-comparison) - Side-by-side comparison.
- [WhatLLM](https://whatllm.org/) - 256 models, 43+ providers, weekly updates.

### Provider Pricing Pages

- [Anthropic](https://docs.anthropic.com/en/docs/about-claude/pricing) | [OpenAI](https://openai.com/api/pricing/) | [Google Gemini](https://ai.google.dev/gemini-api/docs/pricing) | [DeepSeek](https://api-docs.deepseek.com/quick_start/pricing) | [Mistral](https://mistral.ai/pricing)

## Prompt Engineering for Efficiency

### Official Guides

- [Anthropic Prompt Engineering](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview) - Master guide.
- [Anthropic Claude 4 Best Practices](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices) - Model-specific.
- [Anthropic Interactive Tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial) - 9-chapter course.
- [Anthropic Tool Search](https://www.anthropic.com/engineering/advanced-tool-use) - 85% token reduction for large tool libraries.
- [OpenAI Prompt Engineering](https://developers.openai.com/api/docs/guides/prompt-engineering) - Strategies and tactics.
- [OpenAI Cost Optimization](https://developers.openai.com/api/docs/guides/cost-optimization) - Input minimization, model selection, caching.
- [OpenAI Optimization Cookbook](https://developers.openai.com/cookbook/topic/optimization) - Collection of notebooks.
- [Token-Efficient Tool Use (Anthropic)](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/token-efficient-tool-use) - 70% output token reduction.

### Community

- [PromptingGuide: Optimizing](https://www.promptingguide.ai/guides/optimizing-prompts) - Compression, abstraction, filtering.
- [Prompt Bloat Impact (MLOps)](https://mlops.community/the-impact-of-prompt-bloat-on-llm-output-quality/) - Quality degrades with bloat.

### Concise Reasoning Research

- [Concise Chain-of-Thought](https://arxiv.org/abs/2401.05618) - 48.7% shorter responses, negligible quality loss.
- [Chain of Draft](https://arxiv.org/abs/2502.18600) - Only 7.6% of CoT tokens while matching accuracy.
- [Token Complexity](https://arxiv.org/abs/2503.01141) - Each task has intrinsic minimum tokens for success.
- [Verbosity != Veracity](https://arxiv.org/abs/2411.07858) - Demystifying verbosity in LLM outputs.
- [Incorporating Token Usage](https://arxiv.org/abs/2505.14880) - Token usage as prompting strategy metric.

## Comprehensive Guides

- [8 Strategies to Cut API Spend 80% (2026)](https://blog.premai.io/llm-cost-optimization-8-strategies-that-cut-api-spend-by-80-2026-guide/)
- [Redis Token Optimization](https://redis.io/blog/llm-token-optimization-speed-up-apps/) - Semantic caching, ~73% cost reduction.
- [How I Reduced Token Costs by 90%](https://medium.com/@ravityuval/how-i-reduced-llm-token-costs-by-90-using-prompt-rag-and-ai-agent-optimization-f64bd1b56d9f)
- [LLM Token Optimization Strategies](https://www.tokenoptimize.dev/guides/llm-token-optimization-strategies)
- [Monitor and Cut LLM Costs 90% (Helicone)](https://www.helicone.ai/blog/monitor-and-optimize-llm-costs)
- [LLM Caching Strategies (CostLens)](https://costlens.dev/blog/llm-caching-strategies) - "90% savings most developers don't know about"
- [AI Agent Cost Optimization](https://callsphere.tech/blog/ai-agent-cost-optimization-strategies-production) - 60-70% of agent calls suit small models.
- [Practical Cost + Latency Reduction](https://www.getmaxim.ai/articles/how-to-reduce-llm-cost-and-latency-a-practical-guide-for-production-ai/)
- [Vantage LLM Cost Guide](https://www.vantage.sh/blog/optimize-large-language-model-costs) - Enterprise monitoring.
- [Semantic Highlight for RAG (Zilliz)](https://huggingface.co/blog/zilliz/zilliz-semantic-highlight-model) - 70-80% token reduction.
- [Optimizing LLM in Production (HuggingFace)](https://huggingface.co/blog/optimize-llm) - Quantization, Flash Attention.
- [HuggingFace Inference Optimization](https://huggingface.co/docs/transformers/main/llm_optims) - Transformers library.

## Academic Papers

### Prompt Compression

| Paper | Year | Key Result |
|-------|------|-----------|
| [Prompt Compression Survey](https://arxiv.org/abs/2410.12388) | 2024 | Comprehensive survey of all techniques |
| [LLMLingua](https://arxiv.org/abs/2310.05736) | 2023 | Up to 20x compression (EMNLP) |
| [LLMLingua-2](https://arxiv.org/abs/2403.12968) | 2024 | 3-6x faster via BERT distillation (ACL) |
| [LongLLMLingua](https://arxiv.org/abs/2310.06839) | 2023 | 4x fewer tokens in long contexts |
| [Selective Context](https://arxiv.org/abs/2310.06201) | 2023 | 50% reduction via self-information pruning |
| [RECOMP](https://arxiv.org/abs/2310.04408) | 2023 | 5% token ratio for retrieved docs |
| [500xCompressor](https://arxiv.org/abs/2408.03094) | 2024 | 6-480x compression ratios |
| [LoPace](https://arxiv.org/abs/2602.13266) | 2026 | Lossless; 72.2% savings |
| [SCOPE](https://arxiv.org/abs/2508.15813) | 2025 | Training-free generative rewriting |
| [Dynamic Compressing](https://arxiv.org/abs/2504.11004) | 2025 | MDP-based adaptive token removal |
| [Empirical Study](https://arxiv.org/abs/2505.00019) | 2025 | Benchmarks 6 methods across 13 datasets |

### Model Routing & Cascading

| Paper | Year | Key Result |
|-------|------|-----------|
| [FrugalGPT](https://arxiv.org/abs/2305.05176) | 2023 | Seminal cascade paper; up to 98% cost reduction |
| [RouteLLM](https://arxiv.org/abs/2406.18665) | 2024 | 2x+ cost reduction without quality loss |
| [Hybrid LLM](https://arxiv.org/abs/2404.14618) | 2024 | 40% fewer calls to large model |
| [Unified Routing + Cascading](https://arxiv.org/abs/2410.10347) | 2024 | +14% over individual strategies |
| [Dynamic Routing Survey](https://arxiv.org/abs/2603.04445) | 2026 | Comprehensive survey |
| [Pay for Hints](https://arxiv.org/abs/2601.22132) | 2026 | Small model gets hints, not full answers |

### Context & Inference

| Paper | Year | Key Result |
|-------|------|-----------|
| [Lost in the Middle](https://arxiv.org/abs/2307.03172) | 2023 | Models struggle with mid-context info |
| [Context Rot](https://research.trychroma.com/context-rot) | 2025 | Degradation before context limits |
| [RAG vs Long Context](https://arxiv.org/abs/2501.01880) | 2025 | Complementary strengths by query type |
| [Self-Route Hybrid](https://arxiv.org/abs/2407.16833) | 2024 | Adaptive RAG + long context |
| [InfiniteICL](https://arxiv.org/abs/2504.01707) | 2025 | 90% reduction, 103% performance |
| [YaRN Context Extension](https://arxiv.org/abs/2309.00071) | 2023 | 10x less tokens for context extension |
| [SkyLadder](https://arxiv.org/abs/2503.15450) | 2025 | 22% training time savings |
| [TRIM](https://arxiv.org/abs/2412.07682) | 2024 | 19.4% token savings on GPT-4o |

### KV Cache & Inference

| Paper | Year | Key Result |
|-------|------|-----------|
| [PagedAttention (vLLM)](https://arxiv.org/abs/2309.06180) | 2023 | Near-zero KV cache waste |
| [RadixAttention (SGLang)](https://arxiv.org/abs/2312.07104) | 2023 | Auto KV cache reuse |
| [KV Cache Survey (2026)](https://arxiv.org/abs/2603.20397) | 2026 | Comprehensive techniques survey |
| [VectorQ Semantic Caching](https://arxiv.org/abs/2502.03771) | 2025 | Up to 100x latency reduction |
| [KV-Compress](https://arxiv.org/abs/2410.00161) | 2024 | Variable-head-rate compression |
| [vAttention](https://arxiv.org/abs/2405.04437) | 2024 | 1.99x throughput over vLLM |
| [LazyLLM](https://arxiv.org/abs/2407.14057) | 2024 | Dynamic token pruning at prefill |
| [SlimInfer](https://arxiv.org/abs/2508.06447) | 2025 | 1.88x latency reduction |
| [Mirror Speculative Decoding](https://arxiv.org/abs/2510.13161) | 2025 | Breaks serial barrier |
| [LongSpec](https://arxiv.org/abs/2502.17421) | 2025 | Constant memory speculative decoding |
| [Speculative Speculative Decoding](https://arxiv.org/abs/2603.03251) | 2026 | Parallelizes speculation+verification; 30% faster than standard SD (ICLR 2026) |
| [IceCache](https://arxiv.org/abs/2604.10539) | 2026 | Semantic clustering for KV pages; 99% accuracy at 25% token budget |

### Prompt Optimization

| Paper | Year | Key Result |
|-------|------|-----------|
| [APE (Automatic Prompt Engineer)](https://arxiv.org/abs/2211.01910) | 2022 | LLMs generate optimal prompts |
| [Concise Chain-of-Thought](https://arxiv.org/abs/2401.05618) | 2024 | 48.7% shorter, negligible quality loss |
| [Chain of Draft](https://arxiv.org/abs/2502.18600) | 2025 | Only 7.6% of CoT tokens used |
| [Semantic Compression](https://arxiv.org/abs/2304.12512) | 2023 | Semantic compression with LLMs |
| [Tokenomics](https://arxiv.org/abs/2601.14470) | 2026 | Code review = 59.4% of tokens in agentic SE; input context dominates at 53.9% |

## Community Resources

### Blogs

- [Simon Willison: LLM Pricing](https://simonwillison.net/tags/llm-pricing/) - Ongoing coverage of cost collapse.
- [Simon Willison: LLMs in 2024](https://simonwillison.net/2024/Dec/31/llms-in-2024/) - MoE efficiency, cost trends.
- [Eugene Yan: LLM Patterns](https://eugeneyan.com/writing/llm-patterns/) - Caching (50%+ savings), fine-tuning, RAG, guardrails.
- [Chip Huyen: AI OSS Analysis](https://huyenchip.com/2024/03/14/ai-oss.html) - 900 most popular AI tools analyzed.
- [goodailist.com](https://goodailist.com) - Daily-updated tracker of 15K+ AI repos.

### Discussions

- [HN: How Are You Handling LLM API Costs in Production?](https://news.ycombinator.com/item?id=46229585)
- [HN: The LLM Agent Cost Curve](https://news.ycombinator.com/item?id=47000034)
- [HN: Genosis - LLM Cost Optimization](https://news.ycombinator.com/item?id=47516438)

### Podcasts

- [Latent Space: Artificial Analysis](https://www.latent.space/p/artificialanalysis) - The "smiling curve of AI costs".

---

## License

[![CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

This work is licensed under [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/).
