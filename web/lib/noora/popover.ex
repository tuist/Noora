defmodule Noora.Popover do
  @moduledoc """
  Renders a popover component with a trigger and customizable content.

  ## Example

  ```elixir
  <.popover id="settings-popover">
    <:trigger :let={attrs}>
      <button {attrs}>Settings</button>
    </:trigger>
    <div>
      <h3>Popover Content</h3>
      <p>This is the content inside the popover.</p>
    </div>
  </.popover>

  <.popover id="form-popover" placement="bottom-end">
    <:trigger :let={attrs}>
      <span {attrs}><.icon name="filter" /></span>
    </:trigger>
    <form phx-submit="save">
      <.text_input name="name" label="Name" />
      <.button type="submit" label="Save" />
    </form>
  </.popover>
  ```
  """
  use Phoenix.Component

  attr(:id, :string, required: true, doc: "Unique identifier for the popover")
  attr(:disabled, :boolean, default: false, doc: "Whether the popover is disabled")

  attr(:placement, :string,
    default: "bottom-start",
    doc: "Positioning placement for the popover"
  )

  attr(:open_delay, :integer, default: 0, doc: "Delay in ms before opening")
  attr(:close_delay, :integer, default: 0, doc: "Delay in ms before closing")
  attr(:interactive, :boolean, default: true, doc: "Whether the popover is interactive")

  attr(:rest, :global, doc: "Additional HTML attributes")

  slot(:trigger, required: true, doc: "Trigger element for the popover")
  slot(:inner_block, required: true, doc: "Content to be rendered inside the popover")

  def popover(assigns) do
    ~H"""
    <div
      id={@id}
      class="noora-popover"
      phx-hook="NooraPopover"
      data-open-delay={@open_delay}
      data-close-delay={@close_delay}
      data-interactive={@interactive}
      data-positioning-placement={@placement}
      {@rest}
    >
      {render_slot(@trigger, %{"data-part" => "trigger"})}
      <div data-part="positioner">
        <div data-part="content">
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end
end
