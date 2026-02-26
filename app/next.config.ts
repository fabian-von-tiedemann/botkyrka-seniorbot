import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  outputFileTracingIncludes: {
    "/api/chat": ["./kb/**/*"],
  },
  async rewrites() {
    return [
      {
        source: "/images/:path*",
        destination: "https://www.botkyrka.se/images/:path*",
      },
      {
        source: "/download/:path*",
        destination: "https://www.botkyrka.se/download/:path*",
      },
      {
        source: "/sitevision/:path*",
        destination: "https://www.botkyrka.se/sitevision/:path*",
      },
      {
        source: "/webdav/:path*",
        destination: "https://www.botkyrka.se/webdav/:path*",
      },
    ];
  },
};

export default nextConfig;
