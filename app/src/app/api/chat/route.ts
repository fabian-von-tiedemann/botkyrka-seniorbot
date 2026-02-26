import { streamText, convertToModelMessages } from "ai";
import { openai } from "@ai-sdk/openai";
import { buildSystemPrompt } from "@/lib/system-prompt";

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: openai("gpt-5.2"),
    system: buildSystemPrompt(),
    messages: await convertToModelMessages(messages),
    temperature: 0.3,
    maxOutputTokens: 1500,
  });

  return result.toUIMessageStreamResponse();
}
