# Provider Documentation

Official docs from LLM providers on caching, batching, pricing, and optimization features.

## Anthropic

- [Prompt Caching](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching) - 90% discount, 5min/1hr TTL, min 1,024 tokens
- [Prompt Caching Announcement](https://www.anthropic.com/news/prompt-caching) - Economics blog post
- [Token-Saving Updates](https://www.anthropic.com/news/token-saving-updates) - Cache-aware rate limits, simplified caching
- [Token-Efficient Tool Use](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/token-efficient-tool-use) - 70% output token reduction for tool calls
- [Advanced Tool Use: Tool Search](https://www.anthropic.com/engineering/advanced-tool-use) - 85% token reduction for large tool libraries
- [Extended Thinking + Caching](https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking) - Thinking blocks cached in tool-use loops
- [Message Batches API](https://docs.anthropic.com/en/api/creating-message-batches) - 50% discount, 10K requests, 24hr
- [Message Batches Announcement](https://www.anthropic.com/news/message-batches-api) - GA blog post
- [Token Counting API](https://docs.anthropic.com/en/api/messages-count-tokens) - Free pre-flight counting
- [Pricing](https://docs.anthropic.com/en/docs/about-claude/pricing) - Current model pricing
- [Long Context Tips](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips) - Place docs at top, XML tags
- [Context Windows](https://docs.anthropic.com/en/docs/build-with-claude/context-windows) - How context works, compaction
- [Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) - Smallest high-signal token set
- [Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Managing context across workflows
- [Prompt Engineering Overview](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview) - Master guide
- [Claude 4 Best Practices](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices) - Model-specific
- [Interactive Tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial) - 9-chapter course
- [Claude Code Costs](https://docs.anthropic.com/en/docs/claude-code/costs) - Cost management for Claude Code

## OpenAI

- [Prompt Caching](https://platform.openai.com/docs/guides/prompt-caching) - 50% discount, automatic for 1024+ tokens
- [Prompt Caching Cookbook](https://developers.openai.com/cookbook/examples/prompt_caching_201) - Advanced techniques
- [Batch API](https://platform.openai.com/docs/guides/batch) - 50% discount, 50K requests per file
- [Batch API FAQ](https://help.openai.com/en/articles/9197833-batch-api-faq) - Limits and behavior
- [Cost Optimization Guide](https://developers.openai.com/api/docs/guides/cost-optimization) - Input minimization, model selection, caching
- [Optimization Cookbook](https://developers.openai.com/cookbook/topic/optimization) - Collection of notebooks
- [Prompt Engineering](https://developers.openai.com/api/docs/guides/prompt-engineering) - Strategies and tactics
- [GPT-5.4 Prompt Guidance](https://developers.openai.com/api/docs/guides/prompt-guidance) - Model-specific
- [Pricing](https://openai.com/api/pricing/) - Current model pricing

## Google

- [Gemini Context Caching](https://ai.google.dev/gemini-api/docs/caching) - Implicit and explicit, 90% discount
- [Vertex AI Caching](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/context-cache/context-cache-overview) - Enterprise caching
- [Gemini Batch API](https://ai.google.dev/gemini-api/docs/batch-api) - 50% discount, combinable with caching
- [Vertex Batch Prediction](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/batch-prediction-gemini) - Enterprise batch
- [Pricing](https://ai.google.dev/gemini-api/docs/pricing) - Current model pricing

## DeepSeek

- [KV Cache](https://api-docs.deepseek.com/guides/kv_cache) - Disk-based, 64-token granularity, 90% savings
- [Caching Announcement](https://api-docs.deepseek.com/news/news0802) - Feature announcement
- [Pricing](https://api-docs.deepseek.com/quick_start/pricing) - Current pricing
- [Pricing Details (USD)](https://api-docs.deepseek.com/quick_start/pricing-details-usd) - Including cache hit pricing

## Mistral

- [Pricing](https://mistral.ai/pricing) - Large 3, Medium 3, Small 3.1
