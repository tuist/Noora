defmodule TuistWeb.Storybook.DatePicker do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Noora.DatePicker

  def function, do: &DatePicker.date_picker/1

  def variations do
    [
      %Variation{
        id: :default,
        description: "Date picker with default presets",
        attributes: %{
          id: "date-picker-default",
          open: true,
          selected_preset: "7d"
        }
      }
    ]
  end
end
