/** @type { import('@storybook/web-components').Preview } */

// Import Noora CSS tokens for theming
import "../../web/css/tokens.css";

const preview = {
  parameters: {
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/i,
      },
    },
    backgrounds: {
      default: "light",
      values: [
        { name: "light", value: "#ffffff" },
        { name: "dark", value: "#1a1a1a" },
      ],
    },
  },
  decorators: [
    (Story, context) => {
      // Apply dark theme based on background selection
      const isDark = context.globals.backgrounds?.value === "#1a1a1a";
      document.documentElement.setAttribute(
        "data-theme",
        isDark ? "dark" : "light"
      );
      return Story();
    },
  ],
};

export default preview;
