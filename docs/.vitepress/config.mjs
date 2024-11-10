import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Noora",
  description: "A design system for building CLIs in Swift",
  titleTemplate: ":title · Noora · Tuist",
  lastUpdated: true,
  srcDir: "content",
  cleanUrls: true,
  head: [
    ["meta", { property: "og:url", content: "https://noora.tuist.dev" }, ""],
    ["meta", { property: "og:type", content: "website" }, ""],
    [
      "meta",
      { property: "og:image", content: "https://noora.tuist.dev/og.jpeg" },
      "",
    ],
    ["meta", { name: "twitter:card", content: "summary" }, ""],
    ["meta", { property: "twitter:domain", content: "noora.tuist.dev" }, ""],
    ["meta", { property: "twitter:url", content: "https://noora.tuist.dev" }, ""],
    [
      "meta",
      {
        name: "twitter:image",
        content: "https://noora.tuist.dev/og.jpeg",
      },
      "",
    ],
  ],
  sitemap: {
    hostname: "https://noora.tuist.dev",
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [{ text: "Home", link: "/" }],
    logo: "/logo.png",

    sidebar: [
      {
        text: "Components",
        items: [
          { text: "YesOrNoPrompt", link: "/components/yes-or-no-prompt" },
        ],
      },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/tuist/tuist" },
      { icon: "x", link: "https://x.com/tuistdev" },
      { icon: "mastodon", link: "https://fosstodon.org/@tuist" },
      {
        icon: "slack",
        link: "https://join.slack.com/t/tuistapp/shared_invite/zt-1y667mjbk-s2LTRX1YByb9EIITjdLcLw",
      }
    ],
    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright © 2024-present Tuist GmbH",
    }
    
  },
});
