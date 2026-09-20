---
name: ai-sdk-agent
description: Build the product AI agent with Vercel AI SDK v7 (ai@7, @ai-sdk/openai@4, @ai-sdk/react@4) — tool loop, approval for write tools, UI stream, mock-model tests. Use whenever creating or changing the agent, its tools, the chat route or the trace UI.
---

# AI SDK v7 agent — exact names (checked 2026-09-20 against ai@7.0.x docs)

Server (lib/agent.ts):

```ts
import { ToolLoopAgent, tool, isStepCount, Output } from 'ai';
import { openai } from '@ai-sdk/openai';
import { z } from 'zod';
import { db } from './db';

export const tools = {
  search_items: tool({
    description: 'Find records matching a filter',
    inputSchema: z.object({ query: z.string().min(1), limit: z.number().int().max(50).default(10) }),
    execute: async ({ query, limit }) => db.search(query, limit),
  }),
  update_status: tool({
    description: 'Change status of one record (write action, needs approval)',
    inputSchema: z.object({ id: z.string(), status: z.enum(['open', 'done']), reason: z.string() }),
    execute: async (input) => db.updateStatus(input),
  }),
};

export const agent = new ToolLoopAgent({
  model: openai(process.env.AGENT_MODEL ?? 'gpt-5-mini'),
  instructions: 'You are an operator assistant. Read first, then act. Explain every write in one sentence.',
  tools,
  stopWhen: isStepCount(6),
  toolApproval: { update_status: 'user-approval' },
  onStepEnd: ({ stepNumber, toolCalls }) => console.log('step', stepNumber, toolCalls.length),
});
```

Route (app/api/agent/route.ts):

```ts
import { createAgentUIStreamResponse } from 'ai';
import { agent } from '@/lib/agent';
export const maxDuration = 60;
export async function POST(req: Request) {
  const { messages } = await req.json();
  return createAgentUIStreamResponse({ agent, uiMessages: messages });
}
```

Client (components/agent-panel.tsx):

```ts
import { useChat } from '@ai-sdk/react';
import { lastAssistantMessageIsCompleteWithToolCalls } from 'ai';
const { messages, sendMessage, addToolApprovalResponse, status } = useChat({
  sendAutomaticallyWhen: lastAssistantMessageIsCompleteWithToolCalls,
});
// message.parts: type 'text' | 'tool-<name>' (static) | 'dynamic-tool'
// part.state: 'input-streaming' | 'input-available' | 'approval-requested' | 'approval-responded'
//             | 'output-available' | 'output-error' | 'output-denied'
// approval: addToolApprovalResponse({ id: part.approval.id, approved: true })
```

Structured final answer when the task needs a typed result: `output: Output.object({ schema })` on the agent, read `result.output`.

Tests (tests/agent.test.ts): `import { MockLanguageModelV4 } from 'ai/test'`. Pass `doGenerate` as an array: first item returns a `tool-call` content part (`toolCallId`, `toolName`, `input` as JSON string, `finishReason: { unified: 'tool-calls', raw: undefined }`), second item returns a `text` part with `finishReason: { unified: 'stop', raw: undefined }`. Build a ToolLoopAgent with that model and the real tools against a seeded test db; assert the db changed.

Rules:
- Read tools execute; write tools go through toolApproval. Never fake a tool result.
- Default step limit 6. Rely on route `maxDuration = 60` for the time budget.
- Model id via env. Fallback provider: `createOpenAICompatible({ name: 'nvidia', baseURL: 'https://integrate.api.nvidia.com/v1', apiKey: process.env.NVIDIA_API_KEY })` from '@ai-sdk/openai-compatible', only when OPENAI_API_KEY is missing and NVIDIA_API_KEY is present.
- If a name above does not exist in node_modules/ai, open node_modules/ai/README.md and node_modules/ai/dist/index.d.ts and use the real name. Do not guess.
