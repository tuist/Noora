defmodule NooraStorybookWeb.Storybook do
  use PhoenixStorybook,
    otp_app: :noora_storybook_web,
    title: "Noora Storybook",
    content_path: Path.expand("../../storybook", __DIR__),
    css_path: "/assets/storybook.css",
    js_path: "/assets/storybook.js",
    sandbox_class: "noora-storybook-web",
    color_mode: true,
    color_mode_sandbox_dark_class: "noora-dark"
end
