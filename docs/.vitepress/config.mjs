import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "SwiftTerminal",
  description: "A Swift Package for building top-notch CLIs in Swift",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' }
    ],

    sidebar: [
      {
        text: 'Components',
        items: [
          { text: 'YesOrNoPrompt', link: '/components/yes-or-no-prompt' },
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/tuist/swiftterminal' }
    ]
  }
})
