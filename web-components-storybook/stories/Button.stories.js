import { html } from "lit";

// Import the web component
import "../../web/web-components/NooraButton.js";

export default {
  title: "Components/Button",
  component: "noora-button",
  tags: ["autodocs"],
  argTypes: {
    variant: {
      control: { type: "select" },
      options: ["primary", "secondary", "destructive"],
      description: "The visual style variant of the button",
      table: {
        defaultValue: { summary: "primary" },
      },
    },
    size: {
      control: { type: "select" },
      options: ["small", "medium", "large"],
      description: "The size of the button",
      table: {
        defaultValue: { summary: "large" },
      },
    },
    disabled: {
      control: { type: "boolean" },
      description: "Whether the button is disabled",
      table: {
        defaultValue: { summary: false },
      },
    },
    iconOnly: {
      control: { type: "boolean" },
      description: "Whether the button contains only an icon",
      table: {
        defaultValue: { summary: false },
      },
    },
    label: {
      control: { type: "text" },
      description: "The button label text",
    },
    onClick: {
      action: "clicked",
      description: "Click event handler",
    },
  },
  args: {
    variant: "primary",
    size: "large",
    disabled: false,
    iconOnly: false,
    label: "Button",
  },
};

const Template = ({ variant, size, disabled, iconOnly, label, onClick }) => html`
  <noora-button
    variant=${variant}
    size=${size}
    ?disabled=${disabled}
    ?icon-only=${iconOnly}
    @click=${onClick}
  >
    ${label}
  </noora-button>
`;

export const Primary = Template.bind({});
Primary.args = {
  variant: "primary",
  label: "Primary Button",
};

export const Secondary = Template.bind({});
Secondary.args = {
  variant: "secondary",
  label: "Secondary Button",
};

export const Destructive = Template.bind({});
Destructive.args = {
  variant: "destructive",
  label: "Destructive Button",
};

export const Small = Template.bind({});
Small.args = {
  size: "small",
  label: "Small Button",
};

export const Medium = Template.bind({});
Medium.args = {
  size: "medium",
  label: "Medium Button",
};

export const Large = Template.bind({});
Large.args = {
  size: "large",
  label: "Large Button",
};

export const Disabled = Template.bind({});
Disabled.args = {
  disabled: true,
  label: "Disabled Button",
};

export const DisabledSecondary = Template.bind({});
DisabledSecondary.args = {
  variant: "secondary",
  disabled: true,
  label: "Disabled Secondary",
};

export const DisabledDestructive = Template.bind({});
DisabledDestructive.args = {
  variant: "destructive",
  disabled: true,
  label: "Disabled Destructive",
};

// Icon button example using an inline SVG
const IconTemplate = ({ variant, size, disabled, onClick }) => html`
  <noora-button
    variant=${variant}
    size=${size}
    ?disabled=${disabled}
    icon-only
    @click=${onClick}
  >
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="currentColor"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M12 4.5v15m7.5-7.5h-15"
      />
    </svg>
  </noora-button>
`;

export const IconOnly = IconTemplate.bind({});
IconOnly.args = {
  variant: "primary",
  size: "large",
};

// Button with icon on the left
const WithIconLeftTemplate = ({ variant, size, disabled, label, onClick }) => html`
  <noora-button
    variant=${variant}
    size=${size}
    ?disabled=${disabled}
    @click=${onClick}
  >
    <svg
      slot="icon-left"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="currentColor"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M12 4.5v15m7.5-7.5h-15"
      />
    </svg>
    ${label}
  </noora-button>
`;

export const WithIconLeft = WithIconLeftTemplate.bind({});
WithIconLeft.args = {
  variant: "primary",
  size: "large",
  label: "Add Item",
};

// Button with icon on the right
const WithIconRightTemplate = ({ variant, size, disabled, label, onClick }) => html`
  <noora-button
    variant=${variant}
    size=${size}
    ?disabled=${disabled}
    @click=${onClick}
  >
    ${label}
    <svg
      slot="icon-right"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="currentColor"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"
      />
    </svg>
  </noora-button>
`;

export const WithIconRight = WithIconRightTemplate.bind({});
WithIconRight.args = {
  variant: "primary",
  size: "large",
  label: "Continue",
};

// All variants showcase
export const AllVariants = () => html`
  <div style="display: flex; gap: 1rem; flex-wrap: wrap; align-items: center;">
    <noora-button variant="primary">Primary</noora-button>
    <noora-button variant="secondary">Secondary</noora-button>
    <noora-button variant="destructive">Destructive</noora-button>
  </div>
`;

// All sizes showcase
export const AllSizes = () => html`
  <div style="display: flex; gap: 1rem; flex-wrap: wrap; align-items: center;">
    <noora-button size="small">Small</noora-button>
    <noora-button size="medium">Medium</noora-button>
    <noora-button size="large">Large</noora-button>
  </div>
`;
