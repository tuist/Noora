defmodule Noora.DismissIcon do
  @moduledoc """
  Renders a dismiss icon button for closing or removing elements, with customizable size.
  """
  use Phoenix.Component

  import Noora.Icon

  attr :size, :string, values: ~w(small large), default: "large", doc: "The size of the icon"
  attr :on_dismiss, :string, default: nil
  attr :rest, :global, include: ~w(disabled)

  def dismiss_icon(assigns) do
    ~H"""
    <button
      class="noora-dismiss-icon"
      phx-click={@on_dismiss}
      data-size={@size}
      aria-label="Dismiss"
      type="button"
      {@rest}
    >
      <.close />
    </button>
    """
  end
end
