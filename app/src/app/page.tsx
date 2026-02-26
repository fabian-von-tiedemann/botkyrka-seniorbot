"use client";

import { useState, useEffect } from "react";
import { ChatWidget } from "@/components/chat/chat-widget";
import { Bot } from "lucide-react";

export default function Home() {
  const [chatOpen, setChatOpen] = useState(false);

  // Listen for postMessage from iframe (Seniorbot block button)
  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      if (e.data === "openSeniorbot") setChatOpen(true);
    }
    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  return (
    <>
      {/* Original Botkyrka page in iframe — pixel-perfect reproduction */}
      <iframe
        src="/aldreomsorg.html"
        title="Äldreomsorg - Botkyrka kommun"
        className="fixed inset-0 h-full w-full border-none"
      />

      {/* Floating Seniorbot button */}
      {!chatOpen && (
        <button
          onClick={() => setChatOpen(true)}
          className="fixed bottom-6 right-6 z-[9998] flex items-center gap-2.5 rounded-full bg-[#c52e7c] px-5 py-3.5 text-[15px] font-semibold text-white shadow-lg transition-transform hover:scale-105 hover:bg-[#a02465] active:scale-95"
          aria-label="Öppna Seniorbot"
        >
          <Bot className="h-5 w-5" />
          Fråga Seniorbot
        </button>
      )}

      {/* Chat widget overlay */}
      <ChatWidget open={chatOpen} onOpenChange={setChatOpen} />
    </>
  );
}
