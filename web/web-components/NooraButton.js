/**
 * Noora Button Web Component
 *
 * A customizable button component that supports multiple variants, sizes, and states.
 * Uses Shadow DOM for encapsulation while inheriting CSS custom properties from the host page.
 *
 * @element noora-button
 *
 * @attr {string} variant - Button variant: "primary" | "secondary" | "destructive" (default: "primary")
 * @attr {string} size - Button size: "small" | "medium" | "large" (default: "large")
 * @attr {boolean} disabled - Whether the button is disabled
 * @attr {boolean} icon-only - Whether the button contains only an icon
 *
 * @slot - Default slot for button content
 * @slot icon-left - Slot for an icon on the left side
 * @slot icon-right - Slot for an icon on the right side
 *
 * @example
 * <noora-button variant="primary" size="large">Click me</noora-button>
 * <noora-button variant="secondary" disabled>Disabled</noora-button>
 * <noora-button icon-only><svg>...</svg></noora-button>
 */

const styles = `
  :host {
    display: inline-flex;
  }

  :host([hidden]) {
    display: none;
  }

  .noora-button {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    -webkit-appearance: button;
    border: 0;
    border-radius: var(--noora-radius-medium, 8px);
    padding: 0;
    text-decoration: none;
    cursor: pointer;
    outline: unset;
    font-family: inherit;
    /* Reserve space for box-shadow to ensure consistent height across variants */
    box-shadow:
      0px 0px 0px 0px transparent,
      0px 0px 0px 0px transparent,
      0px 0px 0px 0px transparent,
      0px 0px 0px 0px transparent;
  }

  .noora-button ::slotted(svg),
  .noora-button svg {
    pointer-events: none;
  }

  .noora-button[disabled] {
    cursor: not-allowed;
  }

  .noora-button > span {
    padding: 0rem var(--noora-spacing-2, 0.375rem);
  }

  /* Primary variant */
  .noora-button[data-variant="primary"] {
    box-shadow: var(--noora-button-border-primary);
    background: var(--noora-button-background-primary);
    color: var(--noora-button-primary-label);
  }

  .noora-button[data-variant="primary"]:hover:not([disabled]) {
    box-shadow: var(--noora-button-border-primary-hover);
    background: var(--noora-button-background-primary-hover);
  }

  .noora-button[data-variant="primary"]:focus {
    box-shadow: var(--noora-button-border-primary-focus);
  }

  .noora-button[data-variant="primary"][disabled] {
    box-shadow: var(--noora-button-border-primary-disabled);
    background: var(--noora-button-background-primary-disabled);
    color: var(--noora-button-primary-disabled-label);
  }

  .noora-button[data-variant="primary"]:not([disabled]):active {
    box-shadow: var(--noora-button-border-primary-active);
    background: var(--noora-button-background-primary-active);
  }

  /* Secondary variant */
  .noora-button[data-variant="secondary"] {
    box-shadow: var(--noora-button-border-secondary);
    background: var(--noora-button-background-secondary);
    color: var(--noora-button-secondary-label);
  }

  .noora-button[data-variant="secondary"]:hover:not([disabled]) {
    background: var(--noora-button-background-secondary-hover);
  }

  .noora-button[data-variant="secondary"]:focus {
    box-shadow: var(--noora-button-border-secondary-focus);
  }

  .noora-button[data-variant="secondary"][disabled] {
    box-shadow: var(--noora-button-border-secondary-disabled);
    background: var(--noora-button-background-secondary-disabled);
    color: var(--noora-button-secondary-disabled-label);
  }

  .noora-button[data-variant="secondary"]:not([disabled]):active {
    box-shadow: var(--noora-button-border-secondary-active);
    background: var(--noora-button-background-secondary-active);
  }

  /* Destructive variant */
  .noora-button[data-variant="destructive"] {
    box-shadow: var(--noora-button-border-destructive);
    background: var(--noora-button-background-destructive);
    color: var(--noora-button-destructive-label);
  }

  .noora-button[data-variant="destructive"]:hover:not([disabled]) {
    box-shadow: var(--noora-button-border-destructive-hover);
    background: var(--noora-button-background-destructive-hover);
  }

  .noora-button[data-variant="destructive"]:focus {
    box-shadow: var(--noora-button-border-destructive-focus);
  }

  .noora-button[data-variant="destructive"][disabled] {
    box-shadow: var(--noora-button-border-destructive-disabled);
    background: var(--noora-button-background-destructive-disabled);
    color: var(--noora-button-destructive-disabled-label);
  }

  .noora-button[data-variant="destructive"]:not([disabled]):active {
    box-shadow: var(--noora-button-border-destructive-active);
    background: var(--noora-button-background-destructive-active);
  }

  /* Icon only */
  .noora-button[data-icon-only="true"] {
    padding: var(--noora-spacing-3, 0.5rem);
  }

  /* Small size */
  .noora-button[data-size="small"] {
    font: var(--noora-font-weight-medium, 500) var(--noora-font-body-xsmall, 0.75rem/1rem);
  }

  .noora-button[data-size="small"]:not([data-icon-only="true"]) {
    padding: var(--noora-spacing-3, 0.5rem) var(--noora-spacing-2, 0.375rem);
  }

  .noora-button[data-size="small"] ::slotted(svg),
  .noora-button[data-size="small"] svg {
    width: var(--noora-icon-size-small, 16px);
    height: var(--noora-icon-size-small, 16px);
  }

  /* Medium size */
  .noora-button[data-size="medium"]:not([data-icon-only="true"]),
  .noora-button[data-size="large"]:not([data-icon-only="true"]) {
    padding: var(--noora-spacing-3, 0.5rem);
  }

  .noora-button[data-size="medium"] {
    font: var(--noora-font-weight-medium, 500) var(--noora-font-body-small, 0.875rem/1.25rem);
  }

  .noora-button[data-size="medium"] ::slotted(svg),
  .noora-button[data-size="medium"] svg {
    width: var(--noora-icon-size-medium, 20px);
    height: var(--noora-icon-size-medium, 20px);
  }

  /* Large size */
  .noora-button[data-size="large"] {
    font: var(--noora-font-weight-medium, 500) var(--noora-font-body-medium, 1rem/1.5rem);
  }

  .noora-button[data-size="large"] ::slotted(svg),
  .noora-button[data-size="large"] svg {
    width: var(--noora-icon-size-large, 24px);
    height: var(--noora-icon-size-large, 24px);
  }
`;

export class NooraButton extends HTMLElement {
  static get observedAttributes() {
    return ["variant", "size", "disabled", "icon-only"];
  }

  constructor() {
    super();
    this.attachShadow({ mode: "open" });
  }

  connectedCallback() {
    this.render();
  }

  attributeChangedCallback() {
    if (this.shadowRoot) {
      this.updateButtonAttributes();
    }
  }

  get variant() {
    return this.getAttribute("variant") || "primary";
  }

  set variant(value) {
    this.setAttribute("variant", value);
  }

  get size() {
    return this.getAttribute("size") || "large";
  }

  set size(value) {
    this.setAttribute("size", value);
  }

  get disabled() {
    return this.hasAttribute("disabled");
  }

  set disabled(value) {
    if (value) {
      this.setAttribute("disabled", "");
    } else {
      this.removeAttribute("disabled");
    }
  }

  get iconOnly() {
    return this.hasAttribute("icon-only");
  }

  set iconOnly(value) {
    if (value) {
      this.setAttribute("icon-only", "");
    } else {
      this.removeAttribute("icon-only");
    }
  }

  updateButtonAttributes() {
    const button = this.shadowRoot.querySelector("button");
    if (button) {
      button.setAttribute("data-variant", this.variant);
      button.setAttribute("data-size", this.size);
      button.setAttribute("data-icon-only", this.iconOnly.toString());
      if (this.disabled) {
        button.setAttribute("disabled", "");
      } else {
        button.removeAttribute("disabled");
      }
    }
  }

  render() {
    this.shadowRoot.innerHTML = `
      <style>${styles}</style>
      <button
        class="noora-button"
        data-variant="${this.variant}"
        data-size="${this.size}"
        data-icon-only="${this.iconOnly}"
        ${this.disabled ? "disabled" : ""}
        part="button"
      >
        <slot name="icon-left"></slot>
        <span><slot></slot></span>
        <slot name="icon-right"></slot>
      </button>
    `;
  }
}

// Register the custom element
if (!customElements.get("noora-button")) {
  customElements.define("noora-button", NooraButton);
}

export default NooraButton;
