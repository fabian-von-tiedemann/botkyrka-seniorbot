import { cn } from "@/lib/utils";
import { Bot, User } from "lucide-react";
import type { UIMessage } from "@ai-sdk/react";

interface ChatBubbleProps {
  message: UIMessage;
}

function getTextContent(message: UIMessage): string {
  return message.parts
    .filter((part): part is { type: "text"; text: string } => part.type === "text")
    .map((part) => part.text)
    .join("");
}

function renderMarkdown(text: string) {
  const lines = text.split("\n");
  const elements: React.ReactNode[] = [];
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    // Headings (##, ###, ####)
    const headingMatch = line.match(/^(#{2,4})\s+(.+)/);
    if (headingMatch) {
      elements.push(
        <p key={i} className="mt-2 font-bold">
          {formatInline(headingMatch[2])}
        </p>
      );
      i++;
      continue;
    }

    // Blockquotes
    if (line.startsWith("> ")) {
      const quoteLines: string[] = [];
      while (i < lines.length && lines[i].startsWith("> ")) {
        quoteLines.push(lines[i].slice(2));
        i++;
      }
      elements.push(
        <div key={`bq-${i}`} className="my-1 border-l-2 border-gray-300 pl-3 italic text-gray-600">
          {formatInline(quoteLines.join(" "))}
        </div>
      );
      continue;
    }

    // Bullet lists — collect consecutive lines
    if (/^[-•*] /.test(line)) {
      const items: string[] = [];
      while (i < lines.length && /^[-•*] /.test(lines[i])) {
        items.push(lines[i].replace(/^[-•*] /, ""));
        i++;
      }
      elements.push(
        <ul key={`ul-${i}`} className="my-1 list-disc pl-5 space-y-0.5">
          {items.map((item, j) => (
            <li key={j}>{formatInline(item)}</li>
          ))}
        </ul>
      );
      continue;
    }

    // Empty lines
    if (line.trim() === "") {
      i++;
      continue;
    }

    // Regular paragraph
    elements.push(
      <p key={i} className="mt-1">
        {formatInline(line)}
      </p>
    );
    i++;
  }

  return elements;
}

function formatInline(text: string): React.ReactNode {
  // Handle **bold** markers
  const parts = text.split(/(\*\*[^*]+\*\*)/g);
  if (parts.length === 1) return text;
  return parts.map((part, i) => {
    if (part.startsWith("**") && part.endsWith("**")) {
      return <strong key={i}>{part.slice(2, -2)}</strong>;
    }
    return part;
  });
}

export function ChatBubble({ message }: ChatBubbleProps) {
  const isBot = message.role === "assistant";
  const text = getTextContent(message);

  if (!text) return null;

  return (
    <div className={cn("flex gap-3", isBot ? "flex-row" : "flex-row-reverse")}>
      <div
        className={cn(
          "flex h-8 w-8 shrink-0 items-center justify-center rounded-full",
          isBot ? "bg-[#c52e7c]/15 text-[#c52e7c]" : "bg-blue-100 text-blue-700"
        )}
      >
        {isBot ? <Bot className="h-4 w-4" /> : <User className="h-4 w-4" />}
      </div>
      <div
        className={cn(
          "max-w-[80%] rounded-2xl px-4 py-3 text-[15px] leading-relaxed",
          isBot
            ? "rounded-tl-md bg-gray-100 text-gray-900"
            : "rounded-tr-md bg-[#c52e7c] text-white"
        )}
      >
        <div className="break-words">
          {isBot ? renderMarkdown(text) : <span className="whitespace-pre-wrap">{text}</span>}
        </div>
      </div>
    </div>
  );
}
