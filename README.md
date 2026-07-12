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

| Strategy                 | Savings              | Effort                   | Link                              |
| ------------------------ | -------------------- | ------------------------ | --------------------------------- |
| Prompt caching           | 90% input tokens     | Add cache headers        | Prompt Caching                    |
| Token-efficient tool use | 70% output reduction | Flip a flag              | Prompt Engineering for Efficiency |
| Batch API                | 50%                  | Queue non-urgent work    | Batch APIs                        |
| Model routing            | 60-95%               | Route by task complexity | Model Routing                     |
| Response caching         | 100% on repeats      | Add a cache layer        | Comprehensive Guides              |
| Prompt compression       | 5-20x                | Use LLMLingua            | Prompt Compression                |

**Combined pipeline:** Cache prefix (90%) + route to cheapest model (60-95%) + batch non-urgent (50%) + compress prompts (5-20x) + cache responses (100% on repeats) = **95-99% cost reduction** vs. naive approach.

## Prompt Caching

Reuse previously-processed prompt prefixes to avoid re-computing the same tokens.

### Provider Docs

- [Anthropic Prompt Caching](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching) - 90% discount, 5min/1hr TTL. Minimum cacheable prefix: 4,096 tokens on Opus 4.6/Haiku 4.5, 1,024 on Sonnet 4.6/Opus 4.8/Sonnet 5.
- [Anthropic Caching Announcement](https://www.anthropic.com/news/prompt-caching) - Blog post explaining economics.
- [Anthropic Token-Saving Updates](https://www.anthropic.com/news/token-saving-updates) - Cache-aware rate limits, simplified caching.
- [Anthropic Extended Thinking + Caching](https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking) - Thinking blocks get cached in tool-use loops.
- [OpenAI Prompt Caching](https://platform.openai.com/docs/guides/prompt-caching) - 50% discount, automatic for 1024+ token prompts. Extended cache retention now defaults to 24h on the GPT-5 series (mandatory on GPT-5.5+), keeping prefixes warm far longer.
- [OpenAI Prompt Caching Cookbook](https://developers.openai.com/cookbook/examples/prompt_caching_201) - Advanced techniques with code.
- [Google Gemini Context Caching](https://ai.google.dev/gemini-api/docs/caching) - Implicit (auto) and explicit caching, 90% discount.
- [Google Vertex AI Caching](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/context-cache/context-cache-overview) - Enterprise context caching.
- [DeepSeek KV Cache](https://api-docs.deepseek.com/guides/kv_cache) - Disk-based, 64-token granularity. V4 Flash cache hits: $0.0028/M vs $0.14/M base (98% savings). **Migration:** `deepseek-chat` and `deepseek-reasoner` aliases retire July 24, 2026 — update to `deepseek-v4-flash` or `deepseek-v4-pro`.
- [DeepSeek Context Caching on Disk](https://api-docs.deepseek.com/news/news0802) - Announcement of disk-based context caching cutting input cost ~10x on cache hits.

### Strategy: Cached Prefix Pattern

Structure prompts so the system prompt + user profile is the first ~2,000 tokens. All subsequent calls share this prefix. For bulk operations (e.g., scoring 50 items): 1x full + 49x at 10% = **88% total savings**.

### Tools

- [autocache](https://github.com/montevive/autocache) - Transparent Anthropic proxy that auto-injects `cache_control` breakpoints at optimal positions; up to 90% cost and 85% latency reduction. ![Stars](https://img.shields.io/github/stars/montevive/autocache)

## Batch APIs

50% discounts for non-time-critical requests. Combine with caching for 95% savings.

- [Anthropic Message Batches](https://docs.anthropic.com/en/api/creating-message-batches) - Up to 10,000 requests, 24hr turnaround.
- [Anthropic Batches Announcement](https://www.anthropic.com/news/message-batches-api) - Use cases and GA details.
- [OpenAI Batch API](https://platform.openai.com/docs/guides/batch) - 50% discount, 50K requests per file.
- [OpenAI Batch API FAQ](https://help.openai.com/en/articles/9197833-batch-api-faq) - Limits and behavior.
- [Google Gemini Batch API](https://ai.google.dev/gemini-api/docs/batch-api) - 50% discount, combinable with context caching.
- [Google Vertex Batch Prediction](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/batch-prediction-gemini) - Enterprise batch.
- [Curator](https://github.com/bespokelabsai/curator) - Batch-inference and synthetic-data library; `batch=True` gives ~50% savings across OpenAI/Anthropic/Gemini/Mistral with built-in caching and retries. ![Stars](https://img.shields.io/github/stars/bespokelabsai/curator)

## Model Routing

Route simple tasks to cheaper models. 80% of typical LLM calls don't need the most expensive model.

### Frameworks

- [RouteLLM](https://github.com/lm-sys/RouteLLM) - Open-source LLM router by LMSYS. Trains routers from preference data; 2x+ cost reduction. **Note: last commit Aug 2024; LMSYS team shifted focus to Chatbot Arena.** ![Stars](https://img.shields.io/github/stars/lm-sys/RouteLLM)
- [LiteLLM](https://github.com/BerriAI/litellm) - SDK + proxy for 100+ LLMs with routing, cost tracking. Strategies: least-busy, cost-based, latency-based. ![Stars](https://img.shields.io/github/stars/BerriAI/litellm)
- [NotDiamond](https://github.com/Not-Diamond/notdiamond-python) - Per-query best-model selection. **Note: the Python SDK was archived Dec 2025 (read-only); the [notdiamond.ai](https://www.notdiamond.ai/) service remains active.** ![Stars](https://img.shields.io/github/stars/Not-Diamond/notdiamond-python)
- [Bifrost](https://github.com/maximhq/bifrost) - 50x faster than LiteLLM; adaptive load balancer, 1000+ models. ![Stars](https://img.shields.io/github/stars/maximhq/bifrost)
- [vLLM Semantic Router](https://github.com/vllm-project/semantic-router) - System-level signal-driven router for Mixture-of-Models across cloud, data center, and edge. v0.3 "Themis" (June 2026); SAAR adds session-aware model selection cutting model switches 79% in multi-agent deployments. ![Stars](https://img.shields.io/github/stars/vllm-project/semantic-router)
- [LLMRouter](https://github.com/ulab-uiuc/LLMRouter) - Open-source routing library with 16+ routers (single-round, multi-turn, agentic, personalized) and a unified CLI. ![Stars](https://img.shields.io/github/stars/ulab-uiuc/LLMRouter)
- [Portkey AI Gateway](https://github.com/Portkey-AI/gateway) - Open-source AI gateway routing to 1,600+ LLMs with guardrails, caching, and load balancing. Acquired by Palo Alto Networks (May 2026); gateway remains open-source under Apache 2.0. ![Stars](https://img.shields.io/github/stars/Portkey-AI/gateway)
- [OpenRouter](https://openrouter.ai/docs/quickstart) - Unified API for 300+ models with [auto-router](https://openrouter.ai/docs/guides/routing/routers/auto-router).
- [Martian Router](https://route.withmartian.com/) - Patent-pending; cuts costs 20-97% via "Model Mapping".

### Curated Lists

- [Awesome AI Model Routing](https://github.com/Not-Diamond/awesome-ai-model-routing) - Comprehensive list of routing approaches.

### Research

- [RouteLLM paper](https://www.lmsys.org/blog/2024-07-01-routellm/) - LMSYS blog on cost-quality tradeoffs.
- [IBM LLM Routers](https://research.ibm.com/blog/LLM-routers) - IBM's research on training routers.
- [vLLM Session-Aware Agentic Routing (SAAR)](https://vllm.ai/blog/2026-06-02-session-aware-agentic-routing) - Router-owned session memory with hard locks around tool loops cuts model switches 79% and estimated cost 78.7% in multi-agent deployments.
- [LLM Routing Explained](https://towardsdatascience.com/llm-routing-intuitively-and-exhaustively-explained-5b0789fe27aa/) - Intuitive guide.
- [vLLM Semantic Router paper](https://arxiv.org/abs/2603.04444) - Signal-driven decision routing for Mixture-of-Modality models; composable signal orchestration across heuristic and neural classifiers.

## Prompt Compression

Reduce prompt size while preserving information quality.

### Tools

- [LLMLingua](https://github.com/microsoft/LLMLingua) - Up to 20x compression. Coarse-to-fine iterative method. Integrates with LangChain/LlamaIndex. ![Stars](https://img.shields.io/github/stars/microsoft/LLMLingua)
- [Headroom](https://github.com/chopratejas/headroom) - Compress tool outputs, logs, files, and RAG chunks before they reach the LLM (60-95% fewer tokens); library, proxy, and MCP server. Claude Code/Cursor/Aider compatible.
- [code2prompt](https://github.com/mufeedvh/code2prompt) - Codebase to LLM prompt with token counting. ![Stars](https://img.shields.io/github/stars/mufeedvh/code2prompt)
- [RTK](https://github.com/rtk-ai/rtk) - Single-binary Rust CLI proxy that compresses dev-command output 60-90% before it reaches a coding agent's context. Works with Claude Code, Cursor, Copilot, Gemini CLI. ![Stars](https://img.shields.io/github/stars/rtk-ai/rtk)
- [TOON](https://github.com/toon-format/toon) - Token-Oriented Object Notation: a compact, schema-aware encoding for passing JSON-like data to LLMs; 30-60% fewer tokens than JSON on uniform arrays of objects. ![Stars](https://img.shields.io/github/stars/toon-format/toon)
- [llmtrim](https://github.com/fkiene/llmtrim) - Quality-gated local proxy and MCP server that compresses prompts, tool outputs, and replies before they reach the LLM, reverting any step that doesn't save tokens (project-reported -31% input / -74% output across 112 A/B cases). Rust CLI plus multi-language library bindings and a WebAssembly/JS package. ![Stars](https://img.shields.io/github/stars/fkiene/llmtrim)
- [lean-ctx](https://github.com/yvgude/lean-ctx) - Rust binary context intelligence layer for AI coding agents; 60-90% fewer tokens via shell-output compression and 10 cached-read modes; MCP server with 76 tools and cross-session memory. Works with Claude Code, Cursor, Copilot, Windsurf, Gemini CLI, and 30+ others. ![Stars](https://img.shields.io/github/stars/yvgude/lean-ctx)

### Research

- [CompactPrompt](https://arxiv.org/abs/2510.18043) - Unified prompt + data compression pipeline.
- [Efficient Prompting Survey](https://arxiv.org/abs/2404.01077) - Survey of efficient prompting methods.

_The full prompt-compression paper table lives in the Academic Papers section below._

### Guides

- [LLMLingua Research Blog](https://www.microsoft.com/en-us/research/blog/llmlingua-innovating-llm-efficiency-with-prompt-compression/) - Microsoft Research deep dive.
- [Prompt Compression Tutorial (FreeCodeCamp)](https://www.freecodecamp.org/news/how-to-compress-your-prompts-and-reduce-llm-costs/) - Practical guide with code.
- [Prompt Compression Overview (MLM)](https://machinelearningmastery.com/prompt-compression-for-llm-generation-optimization-and-cost-reduction/) - 6x to 480x compression ratios.
- [Awesome LLM Compression](https://github.com/HuangOwen/Awesome-LLM-Compression) - Curated paper list.

### Lossless Compression Principles

Rule-based lossless distillation achieves **3-4:1 compression** without any model:

**Strip** prose transitions, hedging, rhetoric, and common knowledge. **Preserve** numbers, entities, decisions, constraints, and risks. **Transform** prose into dense bullets and verbose text into semicolon-joined clauses. **Split** into 3,000-5,000 token self-contained sections that load independently.

## Context Window Management

### Key Research

- [Context Rot toolkit (Chroma)](https://github.com/chroma-core/context-rot) - Toolkit reproducing how LLMs degrade well before context limits (18 models tested).
- [RAG vs Long Context (Elastic)](https://www.elastic.co/search-labs/blog/rag-vs-long-context-model-llm) - RAG is 1250x cheaper for many queries.
- [Long Context RAG (Databricks)](https://www.databricks.com/blog/long-context-rag-performance-llms) - Degradation after 32K-64K tokens.
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
- [OpenProvence](https://github.com/hotchpotch/open_provence) - Open reranker-pruner that drops ~99% off-topic sentences and compresses 80-90% of relevant RAG text; CPU-friendly. ![Stars](https://img.shields.io/github/stars/hotchpotch/open_provence)

## KV Cache Optimization

Server-side optimizations for inference efficiency.

### Inference Engines

- [vLLM](https://github.com/vllm-project/vllm) - PagedAttention, high-throughput inference. ![Stars](https://img.shields.io/github/stars/vllm-project/vllm)
- [SGLang](https://github.com/sgl-project/sglang) - RadixAttention for automatic KV cache reuse. ![Stars](https://img.shields.io/github/stars/sgl-project/sglang)
- [GPUStack](https://github.com/gpustack/gpustack) - GPU cluster manager for vLLM/SGLang. ![Stars](https://img.shields.io/github/stars/gpustack/gpustack)
- [NVIDIA Dynamo](https://github.com/ai-dynamo/dynamo) - Datacenter-scale distributed inference with KV-cache-aware routing and disaggregated prefill/decode; ~2x faster TTFT, 7x throughput/GPU. ![Stars](https://img.shields.io/github/stars/ai-dynamo/dynamo)
- [llm-d](https://github.com/llm-d/llm-d) - Kubernetes-native distributed serving with prefix-cache-aware routing and tiered KV offload to CPU/disk (3x output throughput). ![Stars](https://img.shields.io/github/stars/llm-d/llm-d)
- [Mooncake](https://github.com/kvcache-ai/Mooncake) - Distributed KVCache engine (the serving platform behind Moonshot AI's Kimi); integrated into vLLM for high-bandwidth KV-cache transfer and cross-instance prefix reuse across disaggregated prefill/decode. ![Stars](https://img.shields.io/github/stars/kvcache-ai/Mooncake)

### Compression Tools

- [NVIDIA kvpress](https://github.com/NVIDIA/kvpress) - KV cache compression made easy. ![Stars](https://img.shields.io/github/stars/NVIDIA/kvpress)
- [R-KV](https://github.com/Zefan-Cai/R-KV) - Redundancy-aware compression (NeurIPS 2025). ![Stars](https://img.shields.io/github/stars/Zefan-Cai/R-KV)
- [llm-compressor](https://github.com/vllm-project/llm-compressor) - Compression for deployment with vLLM. ![Stars](https://img.shields.io/github/stars/vllm-project/llm-compressor)
- [NVIDIA Model Optimizer](https://github.com/NVIDIA/Model-Optimizer) - Quantization, pruning, distillation, speculative decoding. ![Stars](https://img.shields.io/github/stars/NVIDIA/Model-Optimizer)
- [TurboQuant](https://github.com/tonbistudio/turboquant-pytorch) - Google's ICLR 2026; 5x KV cache compression.
- [aibrix](https://github.com/vllm-project/aibrix) - Cost-efficient infrastructure for GenAI inference. ![Stars](https://img.shields.io/github/stars/vllm-project/aibrix)
- [LMCache](https://github.com/LMCache/LMCache) - KV cache layer for vLLM/SGLang; offloads and reuses caches across engines (CPU/disk/S3) to cut TTFT for long-context, multi-turn, and RAG. ![Stars](https://img.shields.io/github/stars/LMCache/LMCache)
- [kvcached](https://github.com/ovg-project/kvcached) - Virtualized elastic KV cache decoupling virtual/physical GPU memory for dynamic GPU sharing; plugs into vLLM/SGLang. ![Stars](https://img.shields.io/github/stars/ovg-project/kvcached)
- [KVzip](https://github.com/snu-mllab/KVzip) - Query-agnostic KV cache eviction via context reconstruction (NeurIPS 2025 Oral); 3-4x memory reduction, 2x lower latency. ![Stars](https://img.shields.io/github/stars/snu-mllab/KVzip)
- [DeepSpec](https://github.com/deepseek-ai/DeepSpec) - DeepSeek's open-source speculative decoding stack powering DSpark; 60-85% faster on V4-Flash, 57-78% on V4-Pro; outperforms Eagle-3. MIT license. ![Stars](https://img.shields.io/github/stars/deepseek-ai/DeepSpec)

### Research

- [Speculative Sampling](https://github.com/feifeibear/LLMSpeculativeSampling) - Fast inference via speculative decoding.
- [Awesome KV Cache Compression](https://github.com/October2001/Awesome-KV-Cache-Compression) - Must-read paper list.

_The full KV-cache paper table lives in the Academic Papers section below._

### Educational

- [mini-sglang](https://github.com/sgl-project/mini-sglang) - Learn LLM serving internals.
- [tiny-llm](https://github.com/skyzh/tiny-llm) - Build a tiny vLLM on Apple Silicon.

## Browser Tool Efficiency

Different browser automation approaches consume vastly different context.

| Agent            | Output Size                    | Efficiency                                                                            | Link                                                                                 |
| ---------------- | ------------------------------ | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| WebFetch         | ~1.5 KB (AI-summarized)        | **20x better**                                                                        | [Docs](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-fetch-tool) |
| Playwright MCP   | ~10-33 KB (accessibility tree) | Baseline                                                                              | [GitHub](https://github.com/microsoft/playwright-mcp)                                |
| Agent Browser ⚠️ | ~28 KB (accessibility tree)    | Project unmaintained 2026-05 — superseded by browser-use direct mode + Playwright MCP | [GitHub](https://github.com/vercel-labs/agent-browser)                               |
| Lightpanda       | ~16 KB (raw markdown)          | 2x better                                                                             | [GitHub](https://github.com/lightpanda-io/browser)                                   |

For 10-page workflows: WebFetch = ~15KB vs Playwright = ~330KB total context consumed.

### Why Accessibility Trees Are Efficient

The [accessibility tree](https://developer.mozilla.org/en-US/docs/Glossary/Accessibility_tree) strips visual styling to retain only semantic structure (name, role, state, value). 10-50x smaller than raw HTML. See: [Token cost analysis in browser MCPs](https://dev.to/kuroko1t/how-accessibility-tree-formatting-affects-token-cost-in-browser-mcps-n2a).

### Further Reading

- [WebFetch vs WebSearch analysis](https://mikhail.io/2025/10/claude-code-web-tools/) - Deep comparison.
- [browser-use](https://github.com/browser-use/browser-use) - Foundation library for AI browser agents.
- [Chrome full accessibility tree](https://developer.chrome.com/blog/full-accessibility-tree) - DevTools feature.
- [mcp-compressor](https://github.com/atlassian-labs/mcp-compressor) - MCP proxy that shows a compressed tool surface first and fetches full schemas on demand, cutting tokens spent on large MCP tool descriptions. ![Stars](https://img.shields.io/github/stars/atlassian-labs/mcp-compressor)

## Cost Tracking Tools

- [Langfuse](https://github.com/langfuse/langfuse) - Open-source LLM observability + cost tracking. [Cost tracking docs](https://langfuse.com/docs/observability/features/token-and-cost-tracking). Acquired by ClickHouse (Jan 2026); still actively developed, MIT-licensed. ![Stars](https://img.shields.io/github/stars/langfuse/langfuse)
- [Helicone](https://github.com/Helicone/helicone) - LLM observability, 300+ models, SOC 2. [Cost tracking cookbook](https://docs.helicone.ai/guides/cookbooks/cost-tracking). Acquired by Mintlify (Mar 2026); now maintenance-only — security/bug fixes and new-model support continue, no new feature work. ![Stars](https://img.shields.io/github/stars/Helicone/helicone)
- [LiteLLM Spend Tracking](https://docs.litellm.ai/docs/proxy/cost_tracking) - Per-key/team spend tracking and [budget routing](https://docs.litellm.ai/docs/proxy/provider_budget_routing) for the LiteLLM proxy across 100+ LLMs. ![Stars](https://img.shields.io/github/stars/BerriAI/litellm)
- [tokencost](https://github.com/AgentOps-AI/tokencost) - USD cost estimates for 400+ LLMs. ![Stars](https://img.shields.io/github/stars/AgentOps-AI/tokencost)
- [AgentOps](https://github.com/AgentOps-AI/agentops) - Agent monitoring with LLM cost tracking. ![Stars](https://img.shields.io/github/stars/AgentOps-AI/agentops)
- [agenttrace](https://github.com/luoyuctl/agenttrace) - Local-first TUI that reads Claude Code / Codex / Gemini / Aider / Cursor sessions to surface tokens, cost, cache use, retries, and latency. ![Stars](https://img.shields.io/github/stars/luoyuctl/agenttrace)
- [Future AGI traceAI](https://github.com/future-agi/traceAI) - OpenTelemetry-based AI tracing capturing per-call tokens, cost, and latency across 35+ frameworks. ![Stars](https://img.shields.io/github/stars/future-agi/traceAI)
- [ccusage](https://github.com/ryoppippi/ccusage) - Fast local CLI reporting tokens and cost across 14+ coding agents (Claude Code, Codex, Gemini CLI, Copilot); offline, no upload. ![Stars](https://img.shields.io/github/stars/ryoppippi/ccusage)
- [OpenLLMetry](https://github.com/traceloop/openllmetry) - OpenTelemetry-based GenAI observability instrumenting LLM and vector-DB calls with per-call token and latency telemetry. ![Stars](https://img.shields.io/github/stars/traceloop/openllmetry)
- [MLflow](https://github.com/mlflow/mlflow) - Open-source AI/ML platform with GenAI observability in MLflow 3.x: LLM call tracing with per-span token tracking, prompt optimization tooling, and AI Gateway integration for cost control. ![Stars](https://img.shields.io/github/stars/mlflow/mlflow)
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

- [Anthropic Pricing](https://docs.anthropic.com/en/docs/about-claude/pricing) - Official Claude model pricing.
- [OpenAI Pricing](https://openai.com/api/pricing/) - Official OpenAI API pricing.
- [Google Gemini Pricing](https://ai.google.dev/gemini-api/docs/pricing) - Official Gemini API pricing.
- [DeepSeek Pricing](https://api-docs.deepseek.com/quick_start/pricing) - Official DeepSeek pricing.
- [Mistral Pricing](https://mistral.ai/pricing) - Official Mistral pricing.

### Notable Recent Pricing (June–July 2026)

| Model                 | Input /MTok | Output /MTok | Notes                                                                                                                                        |
| --------------------- | ----------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Claude Fable 5        | $10.00      | $50.00       | Anthropic's most capable model; 1M context (June 2026). Access suspended June 12 via US export-control directive; **restored July 1, 2026**. |
| Claude Opus 4.8       | $5.00       | $25.00       | 1M context at standard pricing                                                                                                               |
| Claude Sonnet 5       | $2.00       | $10.00       | Introductory pricing through Aug 31, 2026 (standard: $3/$15 per MTok); 1M context; most agentic Sonnet; launched June 30, 2026.              |
| GPT-5.5               | $5.00       | $30.00       | OpenAI flagship; 1M context; 90% cached-input discount                                                                                       |
| GPT-5.4               | $2.50       | $15.00       | Half the cost of GPT-5.5; 50% Batch API discount                                                                                             |
| DeepSeek V4 Flash     | $0.14       | $0.28        | Cheapest frontier; 98% cache savings                                                                                                         |
| DeepSeek V4 Pro       | $0.435      | $0.87        | 1M context; thinking + non-thinking modes                                                                                                    |
| Gemini 3.1 Pro        | $2.00       | $12.00       | Preview since Feb 2026; ≤200K context; doubles to $4/$18 above 200K tokens                                                                   |
| Gemini 3.5 Flash      | $1.50       | $9.00        | Launched May 19, 2026; 1M context window                                                                                                     |
| Gemini 2.5 Flash-Lite | $0.10       | $0.40        | Budget option                                                                                                                                |

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

- [Token Complexity](https://arxiv.org/abs/2503.01141) - Each task has intrinsic minimum tokens for success.
- [Verbosity != Veracity](https://arxiv.org/abs/2411.07858) - Demystifying verbosity in LLM outputs.
- [Incorporating Token Usage](https://arxiv.org/abs/2505.14880) - Token usage as prompting strategy metric.

## Comprehensive Guides

- [8 Strategies to Cut API Spend 80% (2026)](https://blog.premai.io/llm-cost-optimization-8-strategies-that-cut-api-spend-by-80-2026-guide/)
- [Redis Token Optimization](https://redis.io/blog/llm-token-optimization-speed-up-apps/) - Semantic caching, ~73% cost reduction.
- [How I Reduced Token Costs by 90%](https://medium.com/@ravityuval/how-i-reduced-llm-token-costs-by-90-using-prompt-rag-and-ai-agent-optimization-f64bd1b56d9f)
- [LLM Token Optimization Strategies](https://www.tokenoptimize.dev/guides/llm-token-optimization-strategies)
- [Monitor and Cut LLM Costs 90% (Helicone)](https://www.helicone.ai/blog/monitor-and-optimize-llm-costs)
- [LLM Caching Strategies (CostLens)](https://costlens.dev/blog/llm-caching-strategies) - "90% savings most developers don't know about."
- [AI Agent Cost Optimization](https://callsphere.tech/blog/ai-agent-cost-optimization-strategies-production) - 60-70% of agent calls suit small models.
- [Practical Cost + Latency Reduction](https://www.getmaxim.ai/articles/how-to-reduce-llm-cost-and-latency-a-practical-guide-for-production-ai/)
- [Vantage LLM Cost Guide](https://www.vantage.sh/blog/optimize-large-language-model-costs) - Enterprise monitoring.
- [Semantic Highlight for RAG (Zilliz)](https://huggingface.co/blog/zilliz/zilliz-semantic-highlight-model) - 70-80% token reduction.
- [Optimizing LLM in Production (Hugging Face)](https://huggingface.co/blog/optimize-llm) - Quantization, Flash Attention.
- [Hugging Face Inference Optimization](https://huggingface.co/docs/transformers/main/llm_optims) - Transformers library.
- [Epoch AI: LLM Inference Price Trends](https://epoch.ai/data-insights/llm-inference-price-trends) - Data showing inference cost per fixed performance halving roughly every two months.
- [ProjectDiscovery: Cut LLM Costs 59% With Caching](https://projectdiscovery.io/blog/how-we-cut-llm-cost-with-prompt-caching) - Raised cache hit rate from 7% to 84% across 9.8B cached tokens.
- [Cockroach Labs: Agentic AI Costs at Scale](https://www.cockroachlabs.com/blog/agentic-ai-costs-at-scale/) - Re-sent context can be 62% of agent inference bills; mitigations.
- [Together AI: Serving DeepSeek-V4 Long Context](https://www.together.ai/blog/serving-deepseek-v4-why-million-token-context-is-an-inference-systems-problem) - Compressed KV layouts and eviction expanding single-node KV capacity 1.2M to 3.7M tokens.
- [GitHub: Token Efficiency in Agentic Workflows](https://github.blog/ai-and-ml/github-copilot/improving-token-efficiency-in-github-agentic-workflows/) - Pruning unused MCP tool schemas and swapping MCP calls for the `gh` CLI cut agentic-CI token spend 43-62% across real workflows.

## Academic Papers

### Prompt Compression

| Paper                                                              | Year | Key Result                                                                                                    |
| ------------------------------------------------------------------ | ---- | ------------------------------------------------------------------------------------------------------------- |
| [Prompt Compression Survey](https://arxiv.org/abs/2410.12388)      | 2024 | Comprehensive survey of all techniques                                                                        |
| [LLMLingua](https://arxiv.org/abs/2310.05736)                      | 2023 | Up to 20x compression (EMNLP)                                                                                 |
| [LLMLingua-2](https://arxiv.org/abs/2403.12968)                    | 2024 | 3-6x faster via BERT distillation (ACL)                                                                       |
| [LongLLMLingua](https://arxiv.org/abs/2310.06839)                  | 2023 | 4x fewer tokens in long contexts                                                                              |
| [Selective Context](https://arxiv.org/abs/2310.06201)              | 2023 | 50% reduction via self-information pruning                                                                    |
| [RECOMP](https://arxiv.org/abs/2310.04408)                         | 2023 | 5% token ratio for retrieved docs                                                                             |
| [500xCompressor](https://arxiv.org/abs/2408.03094)                 | 2024 | 6-480x compression ratios                                                                                     |
| [LoPace](https://arxiv.org/abs/2602.13266)                         | 2026 | Lossless; 72.2% savings                                                                                       |
| [SCOPE](https://arxiv.org/abs/2508.15813)                          | 2025 | Training-free generative rewriting                                                                            |
| [Dynamic Compressing](https://arxiv.org/abs/2504.11004)            | 2025 | MDP-based adaptive token removal                                                                              |
| [Empirical Study](https://arxiv.org/abs/2505.00019)                | 2025 | Benchmarks 6 methods across 13 datasets                                                                       |
| [Telegraph English](https://arxiv.org/abs/2605.04426)              | 2026 | Symbolic rewriting protocol; ~50% token reduction at 99.1% accuracy; outperforms LLMLingua-2 at matched ratio |
| [Prompt Compression in the Wild](https://arxiv.org/abs/2604.02985) | 2026 | First large-scale production study (30K queries) of the latency vs. quality tradeoff                          |
| [Production Compression RCT](https://arxiv.org/abs/2603.23525)     | 2026 | Pre-registered randomized trial: moderate compression −27.9% cost; over-compression backfires                 |
| [LongCodeZip](https://arxiv.org/abs/2510.00446)                    | 2025 | Code-aware two-stage compression; up to 5.6x with no performance loss (ASE 2025)                              |
| [Behavior-Equivalent Token](https://arxiv.org/abs/2511.23271)      | 2025 | Distills a long system prompt into one learned token; no aux model or labels                                  |
| [SAC (Semantic Anchors)](https://arxiv.org/abs/2510.08907)         | 2025 | Autoencoding-free context compression via selected anchor tokens; no compression-token pretraining            |

### Model Routing & Cascading

| Paper                                                               | Year | Key Result                                                                                                       |
| ------------------------------------------------------------------- | ---- | ---------------------------------------------------------------------------------------------------------------- |
| [FrugalGPT](https://arxiv.org/abs/2305.05176)                       | 2023 | Seminal cascade paper; up to 98% cost reduction                                                                  |
| [RouteLLM](https://arxiv.org/abs/2406.18665)                        | 2024 | 2x+ cost reduction without quality loss                                                                          |
| [Hybrid LLM](https://arxiv.org/abs/2404.14618)                      | 2024 | 40% fewer calls to large model                                                                                   |
| [Unified Routing + Cascading](https://arxiv.org/abs/2410.10347)     | 2024 | +14% over individual strategies                                                                                  |
| [Dynamic Routing Survey](https://arxiv.org/abs/2603.04445)          | 2026 | Comprehensive survey                                                                                             |
| [Pay for Hints](https://arxiv.org/abs/2601.22132)                   | 2026 | Small model gets hints, not full answers                                                                         |
| [RouteProfile](https://arxiv.org/abs/2605.00180)                    | 2026 | Graph-based profiling for cold-start routing; handles unseen models using public benchmark signals               |
| [MTRouter](https://arxiv.org/abs/2604.23530)                        | 2026 | Cost-aware multi-turn routing via history-model joint embeddings; 58.7% cost reduction (ACL 2026)                |
| [STEER](https://arxiv.org/abs/2511.06190)                           | 2025 | Confidence-guided stepwise routing between small/large models; no trained router                                 |
| [Routing, Cascades & User Choice](https://arxiv.org/abs/2602.09902) | 2026 | Game-theoretic analysis: optimal routing is usually static with no cascading; exposes provider/user misalignment |

### Context & Inference

| Paper                                                                      | Year | Key Result                                                                                                                         |
| -------------------------------------------------------------------------- | ---- | ---------------------------------------------------------------------------------------------------------------------------------- |
| [Lost in the Middle](https://arxiv.org/abs/2307.03172)                     | 2023 | Models struggle with mid-context info                                                                                              |
| [Context Rot](https://research.trychroma.com/context-rot)                  | 2025 | Degradation before context limits                                                                                                  |
| [RAG vs Long Context](https://arxiv.org/abs/2501.01880)                    | 2025 | Complementary strengths by query type                                                                                              |
| [Self-Route Hybrid](https://arxiv.org/abs/2407.16833)                      | 2024 | Adaptive RAG + long context                                                                                                        |
| [InfiniteICL](https://arxiv.org/abs/2504.01707)                            | 2025 | 90% reduction, 103% performance                                                                                                    |
| [YaRN Context Extension](https://arxiv.org/abs/2309.00071)                 | 2023 | 10x less tokens for context extension                                                                                              |
| [SkyLadder](https://arxiv.org/abs/2503.15450)                              | 2025 | 22% training time savings                                                                                                          |
| [TRIM](https://arxiv.org/abs/2412.07682)                                   | 2024 | 19.4% token savings on GPT-4o                                                                                                      |
| [ILRe](https://arxiv.org/abs/2508.17892)                                   | 2025 | Intermediate-layer retrieval cuts prefill to O(L); ~180x speedup, 1M tokens in ~30s                                                |
| [Context Length Alone Hurts](https://arxiv.org/abs/2510.05381)             | 2025 | Input length itself degrades performance even with perfect retrieval                                                               |
| [ContextBudget (BACM)](https://arxiv.org/abs/2604.01664)                   | 2026 | Budget-aware context management as constrained sequential decision; curriculum RL learns when/how much history to compress         |
| [LCLMs (End-to-End Context Compression)](https://arxiv.org/abs/2606.09659) | 2026 | 0.6B encoder compresses input blocks into latents a 4B decoder consumes directly; ~16x input compression with little accuracy loss |

### KV Cache & Inference

| Paper                                                                | Year | Key Result                                                                                                                        |
| -------------------------------------------------------------------- | ---- | --------------------------------------------------------------------------------------------------------------------------------- |
| [PagedAttention (vLLM)](https://arxiv.org/abs/2309.06180)            | 2023 | Near-zero KV cache waste                                                                                                          |
| [RadixAttention (SGLang)](https://arxiv.org/abs/2312.07104)          | 2023 | Auto KV cache reuse                                                                                                               |
| [KV Cache Survey (2026)](https://arxiv.org/abs/2603.20397)           | 2026 | Comprehensive techniques survey                                                                                                   |
| [VectorQ Semantic Caching](https://arxiv.org/abs/2502.03771)         | 2025 | Up to 100x latency reduction                                                                                                      |
| [KV-Compress](https://arxiv.org/abs/2410.00161)                      | 2024 | Variable-head-rate compression                                                                                                    |
| [vAttention](https://arxiv.org/abs/2405.04437)                       | 2024 | 1.99x throughput over vLLM                                                                                                        |
| [LazyLLM](https://arxiv.org/abs/2407.14057)                          | 2024 | Dynamic token pruning at prefill                                                                                                  |
| [SlimInfer](https://arxiv.org/abs/2508.06447)                        | 2025 | 1.88x latency reduction                                                                                                           |
| [Mirror Speculative Decoding](https://arxiv.org/abs/2510.13161)      | 2025 | Breaks serial barrier                                                                                                             |
| [LongSpec](https://arxiv.org/abs/2502.17421)                         | 2025 | Constant memory speculative decoding                                                                                              |
| [Speculative Speculative Decoding](https://arxiv.org/abs/2603.03251) | 2026 | Parallelizes speculation+verification; 30% faster than standard SD (ICLR 2026)                                                    |
| [IceCache](https://arxiv.org/abs/2604.10539)                         | 2026 | Semantic clustering for KV pages; 99% accuracy at 25% token budget                                                                |
| [Can I Buy Your KV Cache?](https://arxiv.org/abs/2606.13361)         | 2026 | KV cache marketplace: publishers precompute, agents load instead of prefill; 9-50x cheaper compute on Qwen3-4B                    |
| [LMCache](https://arxiv.org/abs/2510.09665)                          | 2025 | KV cache across GPU/CPU/disk/network; up to 15x throughput with vLLM                                                              |
| [KV-Fold](https://arxiv.org/abs/2605.12471)                          | 2026 | One-step KV-cache recurrence; training-free long-context inference                                                                |
| [Thin Keys, Full Values](https://arxiv.org/abs/2603.04427)           | 2026 | SVD-based key-cache compression; up to 16x combined with GQA + quantization                                                       |
| [Make Each Token Count](https://arxiv.org/abs/2605.09649)            | 2026 | Learnable retention gates for KV eviction that improve long-context accuracy                                                      |
| [Meta-Soft](https://arxiv.org/abs/2605.22337)                        | 2026 | Composable meta-tokens for context-preserving KV cache compression                                                                |
| [KeepKV](https://arxiv.org/abs/2504.09936)                           | 2025 | Adaptive lossless merging; 2x+ throughput at 10% KV budget                                                                        |
| [FreeKV](https://arxiv.org/abs/2505.13109)                           | 2025 | Training-free speculative KV retrieval; up to 13x speedup, near-lossless                                                          |
| [SmallKV](https://arxiv.org/abs/2508.02751)                          | 2025 | Small-model-assisted eviction compensation; 1.75-2.56x higher throughput                                                          |
| [Semantic Caching (Microsoft)](https://arxiv.org/abs/2508.07675)     | 2025 | Optimal semantic cache is NP-hard; Reverse Greedy + bandit learning                                                               |
| [SpecFormer](https://arxiv.org/abs/2511.20340)                       | 2025 | Lossless non-autoregressive drafting that holds up under large-batch serving                                                      |
| [LaProx](https://arxiv.org/abs/2605.07234)                           | 2026 | Output-aware, layer-wise KV eviction modeling attention×value interaction; beats prior eviction across 19 LongBench/NIAH datasets |
| [Continuous Semantic Caching](https://arxiv.org/abs/2604.20021)      | 2026 | Theory for semantic caching in continuous embedding space; dynamic ε-net + kernel ridge regression                                |
| [Learning to Draft (LTD)](https://arxiv.org/abs/2603.01639)          | 2026 | RL co-adapts draft+verify policies to optimize true throughput, not acceptance length (ICLR 2026)                                 |
| [DDTree (Block Diffusion)](https://arxiv.org/abs/2604.12989)         | 2026 | Block-diffusion draft tree for speculative decoding; outperforms EAGLE-3 at matched node budget                                   |
| [Graft](https://arxiv.org/abs/2605.20104)                            | 2026 | Training-free prune-then-retrieve framework for speculative decoding draft trees; 5.41× speedup, 21.8% over EAGLE-3 on Qwen3-235B |

### Prompt Optimization

| Paper                                                               | Year | Key Result                                                                                             |
| ------------------------------------------------------------------- | ---- | ------------------------------------------------------------------------------------------------------ |
| [APE (Automatic Prompt Engineer)](https://arxiv.org/abs/2211.01910) | 2022 | LLMs generate optimal prompts                                                                          |
| [Concise Chain-of-Thought](https://arxiv.org/abs/2401.05618)        | 2024 | 48.7% shorter, negligible quality loss                                                                 |
| [Chain of Draft](https://arxiv.org/abs/2502.18600)                  | 2025 | Only 7.6% of CoT tokens used                                                                           |
| [Semantic Compression](https://arxiv.org/abs/2304.12512)            | 2023 | Semantic compression with LLMs                                                                         |
| [Tokenomics](https://arxiv.org/abs/2601.14470)                      | 2026 | Code review = 59.4% of tokens in agentic SE; input context dominates at 53.9%                          |
| [IAPO](https://arxiv.org/abs/2602.19049)                            | 2026 | Information-aware policy optimization; 36% reasoning-length reduction                                  |
| [SelfBudgeter](https://arxiv.org/abs/2505.11274)                    | 2025 | Self-estimated reasoning budget via budget-guided GRPO; ~61% length cut                                |
| [Step Pruner](https://arxiv.org/abs/2510.03805)                     | 2025 | Step-aware RL reward; 33% of tokens at equal accuracy                                                  |
| [BudgetThinker](https://arxiv.org/abs/2508.17196)                   | 2025 | Budget-signaling control tokens for precise reasoning-length control                                   |
| [Extra-CoT](https://arxiv.org/abs/2602.08324)                       | 2026 | Mixed-ratio SFT + RL for extreme-ratio CoT compression; ~73% token cut on MATH-500 with +0.6% accuracy |
| [CROP](https://arxiv.org/abs/2604.14214)                            | 2026 | Length-regularized automatic prompt optimization; up to ~80.6% output-token reduction (Google/Purdue)  |

## Community Resources

### Related Projects

- [LLM Safe Haven](https://github.com/pleasedodisturb/llm-safe-haven) - Security toolkit for AI coding agents. `npx llm-safe-haven` hardens Claude Code, Cursor, Windsurf in 60 seconds. Companion project — agent retries from security failures waste tokens.
- [Awesome AI Efficiency (Pruna)](https://github.com/PrunaAI/awesome-ai-efficiency) - Curated list on making AI faster, cheaper, smaller, and greener.
- [Awesome Efficient LLM](https://github.com/horseee/Awesome-Efficient-LLM) - Large curated list of efficient-LLM papers and tools.

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

_Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). See [LICENSE](LICENSE)._
