defmodule TuistWeb.Storybook.Toggle do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Noora.Toggle.toggle/1

  def variations do
    [
      %VariationGroup{
        id: :basic_states,
        description: "Basic toggle states and interactions",
        variations: [
          %Variation{
            id: :off,
            attributes: %{
              id: "toggle-off",
              label: "Enable notifications"
            }
          },
          %Variation{
            id: :on,
            attributes: %{
              id: "toggle-on",
              label: "Email alerts",
              checked: true
            }
          }
        ]
      },
      %VariationGroup{
        id: :disabled_states,
        description: "Disabled toggle variations",
        variations: [
          %Variation{
            id: :disabled_off,
            attributes: %{
              id: "toggle-disabled-off",
              label: "Disabled off",
              disabled: true
            }
          },
          %Variation{
            id: :disabled_on,
            attributes: %{
              id: "toggle-disabled-on",
              label: "Disabled on",
              disabled: true,
              checked: true
            }
          }
        ]
      },
      %VariationGroup{
        id: :with_descriptions,
        description: "Toggles with additional descriptive text",
        variations: [
          %Variation{
            id: :simple_description,
            attributes: %{
              id: "toggle-simple-description",
              label: "Marketing emails",
              description: "Receive updates about new features and promotions"
            }
          },
          %Variation{
            id: :long_description,
            attributes: %{
              id: "toggle-long-description",
              label: "Data sharing",
              description:
                "Allow us to share anonymized usage data with third-party analytics providers to improve our service quality and user experience"
            }
          },
          %Variation{
            id: :on_with_description,
            attributes: %{
              id: "toggle-on-description",
              label: "Remember my preferences",
              description: "Save your settings for future visits",
              checked: true
            }
          }
        ]
      },
      %VariationGroup{
        id: :practical_examples,
        description: "Real-world toggle usage scenarios",
        variations: [
          %Variation{
            id: :dark_mode,
            attributes: %{
              id: "toggle-dark-mode",
              label: "Enable dark mode",
              description: "Switch to a darker color scheme",
              checked: true
            }
          },
          %Variation{
            id: :auto_save,
            attributes: %{
              id: "toggle-auto-save",
              label: "Auto-save",
              description: "Automatically save changes as you work"
            }
          },
          %Variation{
            id: :notifications,
            attributes: %{
              id: "toggle-notifications",
              label: "Push notifications",
              description: "Receive push notifications on your device"
            }
          }
        ]
      }
    ]
  end
end
