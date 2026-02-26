"use client";

import { useState, type KeyboardEvent } from "react";
import { SendHorizontal } from "lucide-react";
import { Button } from "@/components/ui/button";

interface ChatInputProps {
  isLoading: boolean;
  onSend: (text: string) => void;
}

export function ChatInput({ isLoading, onSend }: ChatInputProps) {
  const [input, setInput] = useState("");

  function handleSubmit() {
    const trimmed = input.trim();
    if (!trimmed || isLoading) return;
    onSend(trimmed);
    setInput("");
  }

  function handleKeyDown(e: KeyboardEvent<HTMLTextAreaElement>) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  }

  return (
    <div className="flex items-end gap-3 border-t bg-white px-5 py-4">
      <textarea
        value={input}
        onChange={(e) => setInput(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="Skriv din fråga här..."
        disabled={isLoading}
        rows={1}
        className="min-h-[52px] max-h-32 flex-1 resize-none rounded-xl border border-gray-300 bg-gray-50 px-4 py-3.5 text-[16px] outline-none placeholder:text-[16px] placeholder:text-gray-400 focus:border-[#c52e7c] focus:ring-1 focus:ring-[#c52e7c] disabled:opacity-50"
        aria-label="Meddelande till Seniorbot"
      />
      <Button
        type="button"
        onClick={handleSubmit}
        disabled={!input.trim() || isLoading}
        size="icon"
        className="h-12 w-12 shrink-0 rounded-xl bg-[#c52e7c] hover:bg-[#a02465] disabled:opacity-40"
        aria-label="Skicka meddelande"
      >
        <SendHorizontal className="h-5 w-5" />
      </Button>
    </div>
  );
}
