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
    [
      "meta",
      { property: "twitter:url", content: "https://noora.tuist.dev" },
      "",
    ],
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
        text: "Noora",
        link: "/",
      },
      {
        text: "Text Styling",
        link: "/text-styling",
      },
      {
        text: "Components",
        items: [
          {
            text: "Prompts",
            collapsed: true,
            items: [
              {
                text: "Yes or no choice",
                link: "/components/prompts/yes-or-no-choice",
              },
              {
                text: "Single choice",
                link: "/components/prompts/single-choice",
              },
              {
                text: "Text",
                link: "/components/prompts/text",
              },
            ],
          },
          {
            text: "Step",
            collapsed: true,
            items: [
              {
                text: "Progress",
                link: "/components/step/progress",
              },
              {
                text: "Collapsible",
                link: "/components/step/collapsible",
              },
            ],
          },
          {
            text: "Alerts",
            collapsed: true,
            items: [
              {
                text: "Success",
                link: "/components/alerts/success",
              },
              {
                text: "Error",
                link: "/components/alerts/error",
              },
              {
                text: "Warning",
                link: "/components/alerts/warning",
              },
            ],
          },
        ],
      },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/tuist/tuist" },
      { icon: "bluesky", link: "https://bsky.app/profile/tuist.dev" },
      { icon: "mastodon", link: "https://fosstodon.org/@tuist" },
      {
        icon: "slack",
        link: "https://join.slack.com/t/tuistapp/shared_invite/zt-1y667mjbk-s2LTRX1YByb9EIITjdLcLw",
      },
    ],
    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright © 2024-present Tuist GmbH",
    },
  },
});
