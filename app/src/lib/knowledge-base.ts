import fs from "fs";
import path from "path";

const KB_DIR = path.join(process.cwd(), "kb");

const KB_FILES = [
  "Systemprompt.md",
  "Struktur för svar.md",
  "Riktlinje för handläggning enligt socialtjänstlagen, antagen 2025-06-16.md",
  "Riktlinje för anhörigstöd, antagen 2025-06-16.md",
  "Avgifter inom vård och omsorg i Botkyrka kommun - riktlinje 2025-06-16.md",
];

let cachedKnowledge: string | null = null;

export function getKnowledgeBase(): string {
  if (cachedKnowledge) return cachedKnowledge;

  const sections: string[] = [];

  for (const file of KB_FILES) {
    const filePath = path.join(KB_DIR, file);
    try {
      const content = fs.readFileSync(filePath, "utf-8");
      const sectionName = file.replace(".md", "");
      sections.push(`\n--- ${sectionName} ---\n\n${content}`);
    } catch {
      console.warn(`KB file not found: ${file}`);
    }
  }

  cachedKnowledge = sections.join("\n");
  return cachedKnowledge;
}
