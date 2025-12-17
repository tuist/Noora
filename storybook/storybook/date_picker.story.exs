defmodule TuistWeb.Storybook.DatePicker do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Noora.DatePicker

  def function, do: &DatePicker.date_picker/1

  def variations do
    [
      %VariationGroup{
        id: :basic,
        description: "Basic date picker with default presets",
        variations: [
          %Variation{
            id: :default,
            description: "Default date picker with all standard presets",
            attributes: %{
              id: "date-picker-default"
            }
          },
          %Variation{
            id: :with_selected_preset,
            description: "Date picker with a pre-selected preset",
            attributes: %{
              id: "date-picker-preset-selected",
              selected_preset: "7d"
            }
          }
        ]
      },
      %VariationGroup{
        id: :custom_presets,
        description: "Date pickers with custom preset configurations",
        variations: [
          %Variation{
            id: :minimal_presets,
            description: "Date picker with minimal preset options",
            attributes: %{
              id: "date-picker-minimal",
              presets: [
                %{id: "7d", label: "Last 7 days", duration: {7, :day}},
                %{id: "30d", label: "Last 30 days", duration: {30, :day}},
                %{id: "custom", label: "Custom", duration: nil}
              ]
            }
          },
          %Variation{
            id: :time_based_presets,
            description: "Date picker with time-based presets",
            attributes: %{
              id: "date-picker-time-based",
              presets: [
                %{id: "1h", label: "Last 1 hour", duration: {1, :hour}},
                %{id: "6h", label: "Last 6 hours", duration: {6, :hour}},
                %{id: "12h", label: "Last 12 hours", duration: {12, :hour}},
                %{id: "24h", label: "Last 24 hours", duration: {24, :hour}},
                %{id: "custom", label: "Custom", duration: nil}
              ]
            }
          },
          %Variation{
            id: :monthly_presets,
            description: "Date picker with month-based presets",
            attributes: %{
              id: "date-picker-monthly",
              presets: [
                %{id: "1m", label: "Last month", duration: {1, :month}},
                %{id: "3m", label: "Last 3 months", duration: {3, :month}},
                %{id: "6m", label: "Last 6 months", duration: {6, :month}},
                %{id: "1y", label: "Last year", duration: {1, :year}},
                %{id: "custom", label: "Custom", duration: nil}
              ]
            }
          }
        ]
      },
      %VariationGroup{
        id: :states,
        description: "Different component states",
        variations: [
          %Variation{
            id: :disabled,
            description: "Disabled date picker",
            attributes: %{
              id: "date-picker-disabled",
              disabled: true
            }
          }
        ]
      },
      %VariationGroup{
        id: :localization,
        description: "Date picker with different locales",
        variations: [
          %Variation{
            id: :german,
            description: "German locale",
            attributes: %{
              id: "date-picker-german",
              locale: "de-DE"
            }
          },
          %Variation{
            id: :french,
            description: "French locale",
            attributes: %{
              id: "date-picker-french",
              locale: "fr-FR"
            }
          },
          %Variation{
            id: :monday_start,
            description: "Week starting on Monday",
            attributes: %{
              id: "date-picker-monday",
              start_of_week: 1
            }
          }
        ]
      }
    ]
  end
end
