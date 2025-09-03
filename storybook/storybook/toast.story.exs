defmodule TuistWeb.Storybook.Berlin do
  @moduledoc false
  use PhoenixStorybook.Story, :page

  def doc, do: "Show floating alerts to users"

  def navigation do
    []
  end

  def render(assigns) do
    ~H"""
    <Noora.Toast.toaster {assigns}/>
    """
  end
end
