"use client";

import { useChat, type UIMessage } from "@ai-sdk/react";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Bot, X } from "lucide-react";
import { ChatMessages } from "./chat-messages";
import { ChatInput } from "./chat-input";
import { Button } from "@/components/ui/button";

interface ChatWidgetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

const WELCOME_MESSAGE: UIMessage = {
  id: "welcome",
  role: "assistant",
  parts: [
    {
      type: "text",
      text: "Hej! Jag är Seniorbot, en digital assistent för frågor om äldreomsorg i Botkyrka kommun. Jag kan hjälpa dig med information om hemtjänst, boenden, avgifter, anhörigstöd och mycket mer.\n\nVad kan jag hjälpa dig med?",
    },
  ],
};

export function ChatWidget({ open, onOpenChange }: ChatWidgetProps) {
  const { messages, sendMessage, status, error } = useChat({
    messages: [WELCOME_MESSAGE],
  });

  const isLoading = status === "submitted" || status === "streaming";

  function handleSend(text: string) {
    sendMessage({ text });
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="right"
        showCloseButton={false}
        className="!z-[10000] flex w-full flex-col gap-0 p-0 text-[16px] sm:max-w-[36rem] [&>button]:hidden"
      >
        {/* Header */}
        <SheetHeader className="shrink-0 border-b bg-[#c52e7c] px-5 py-4 text-white">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white/20">
                <Bot className="h-6 w-6" />
              </div>
              <div>
                <SheetTitle className="text-[18px] font-semibold text-white">
                  Seniorbot
                </SheetTitle>
                <p className="text-[13px] text-white/80">Digital assistent</p>
              </div>
            </div>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => onOpenChange(false)}
              className="h-10 w-10 text-white hover:bg-white/20"
              aria-label="Stäng chatten"
            >
              <X className="h-6 w-6" />
            </Button>
          </div>
        </SheetHeader>

        {/* Disclaimer */}
        <div className="shrink-0 border-b border-amber-200 bg-amber-50 px-5 py-2.5 text-[13px] leading-snug text-amber-800">
          AI-assistent. Svaren är inte juridiskt bindande. Kontakta
          Medborgarservice på 08-530 610 00 för formella besked.
        </div>

        {/* Messages */}
        <ChatMessages messages={messages} isLoading={isLoading} />

        {/* Error */}
        {error && (
          <div className="shrink-0 border-t border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            Något gick fel. Försök igen eller kontakta Medborgarservice på
            08-530 610 00.
          </div>
        )}

        {/* Input */}
        <ChatInput isLoading={isLoading} onSend={handleSend} />
      </SheetContent>
    </Sheet>
  );
}
