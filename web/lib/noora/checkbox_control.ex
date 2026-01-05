defmodule Noora.CheckboxControl do
  @moduledoc false

  use Phoenix.Component

  import Noora.Icon

  @doc """
  Renders just the checkbox control without label or hook.
  Used internally by other Noora components like dropdown items and checkbox.
  """
  attr(:checked, :boolean, default: false, doc: "Whether the checkbox is checked.")
  attr(:indeterminate, :boolean, default: false, doc: "Whether the checkbox is indeterminate.")
  attr(:rest, :global, doc: "Additional attributes")

  def checkbox_control(assigns) do
    state =
      cond do
        assigns.indeterminate -> "indeterminate"
        assigns.checked -> "checked"
        true -> "unchecked"
      end

    assigns = assign(assigns, :state, state)

    ~H"""
    <div
      class="noora-checkbox-control"
      data-state={@state}
      {@rest}
    >
      <div data-part="check"><.check /></div>
      <div data-part="minus"><.minus /></div>
    </div>
    """
  end
end
