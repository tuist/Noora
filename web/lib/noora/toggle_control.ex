defmodule Noora.ToggleControl do
  @moduledoc false

  use Phoenix.Component

  @doc """
  Renders just the toggle control without label or hook.
  Used internally by other Noora components like toggle.
  """
  attr(:checked, :boolean, default: false, doc: "Whether the toggle is checked.")
  attr(:rest, :global, doc: "Additional attributes")

  def toggle_control(assigns) do
    ~H"""
    <div
      class="noora-toggle-control"
      data-state={if @checked, do: "checked", else: "unchecked"}
      {@rest}
    >
      <div data-part="track">
        <div data-part="thumb" />
      </div>
    </div>
    """
  end
end
