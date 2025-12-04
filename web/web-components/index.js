/**
 * Noora Web Components
 *
 * A collection of web components from the Noora Design System.
 * These components use Shadow DOM for encapsulation and CSS custom properties for theming.
 *
 * Usage:
 *   import "@noora/web-components";
 *   // Or import specific components:
 *   import { NooraButton } from "@noora/web-components";
 *
 * Required: Include the Noora CSS tokens in your page for proper theming:
 *   <link rel="stylesheet" href="noora.css" />
 *   // Or import in your JS:
 *   import "noora/noora.css";
 */

export { NooraButton } from "./NooraButton.js";

// Re-export as default for convenience
export default {
  NooraButton: () => import("./NooraButton.js"),
};
