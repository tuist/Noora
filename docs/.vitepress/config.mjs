import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Noora",
  description: "A design system for building CLIs in Swift",
  sitemap: {
    hostname: "https://noora.tuist.dev",
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [{ text: "Home", link: "/" }],

    sidebar: [
      {
        text: "Components",
        items: [
          { text: "YesOrNoPrompt", link: "/components/yes-or-no-prompt" },
        ],
      },
    ],

    socialLinks: [{ icon: "github", link: "https://github.com/tuist/Noora" }],
  },
});
