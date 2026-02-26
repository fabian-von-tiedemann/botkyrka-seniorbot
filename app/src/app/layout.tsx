import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Äldreomsorg – Botkyrka kommun",
  description:
    "Information om äldreomsorg i Botkyrka kommun. Hemtjänst, boenden, avgifter, anhörigstöd och mer. Prata med Seniorbot för snabba svar.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="sv">
      <body>{children}</body>
    </html>
  );
}
