import fs from "fs";
import path from "path";

const KB_PATH = path.join(process.cwd(), "kb", "seniorbot-kunskapsbas.md");

let cachedKnowledge: string | null = null;

export function getKnowledgeBase(): string {
  if (cachedKnowledge) return cachedKnowledge;

  try {
    cachedKnowledge = fs.readFileSync(KB_PATH, "utf-8");
  } catch {
    console.warn(`KB file not found: ${KB_PATH}`);
    cachedKnowledge = "";
  }

  return cachedKnowledge;
}
