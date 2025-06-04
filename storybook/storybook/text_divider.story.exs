defmodule TuistWeb.Storybook.TextDivider do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Noora.TextDivider.text_divider/1

  def variations do
    [
      %Variation{
        id: :text_divider,
        attributes: %{
          text: "OR"
        }
      }
    ]
  end
end
