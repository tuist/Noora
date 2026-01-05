defmodule TuistWeb.Storybook.DropdownCheckbox do
  @moduledoc """
  Interactive example of a dropdown with checkbox items for multi-select functionality.
  """
  use PhoenixStorybook.Story, :example

  import Noora.Dropdown
  import Noora.Icon

  def doc,
    do:
      "Interactive dropdown with checkbox items. Clicking the checkbox toggles without closing. Clicking the label toggles and closes."

  @days [
    %{value: "monday", label: "Monday"},
    %{value: "tuesday", label: "Tuesday"},
    %{value: "wednesday", label: "Wednesday"},
    %{value: "thursday", label: "Thursday"},
    %{value: "friday", label: "Friday"},
    %{value: "saturday", label: "Saturday"},
    %{value: "sunday", label: "Sunday"}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket, selected_days: ["monday", "tuesday", "friday"])}
  end

  def render(assigns) do
    assigns = assign(assigns, :days, @days)

    ~H"""
    <div style="padding: 20px;">
      <.dropdown id="days-dropdown" label={format_selected_days(@selected_days)}>
        <.dropdown_item
          :for={day <- @days}
          value={day.value}
          label={day.label}
          checkbox={true}
          checked={day.value in @selected_days}
          phx-click="toggle_day"
          phx-value-day={day.value}
        />
      </.dropdown>

      <p style="margin-top: 16px; color: #666;">
        Selected: {@selected_days |> Enum.join(", ")}
      </p>
    </div>
    """
  end

  def handle_event("toggle_day", %{"day" => day}, socket) do
    selected_days = socket.assigns.selected_days

    new_selected_days =
      if day in selected_days do
        Enum.reject(selected_days, &(&1 == day))
      else
        [day | selected_days]
      end

    {:noreply, assign(socket, selected_days: new_selected_days)}
  end

  defp format_selected_days([]), do: "Select days"

  defp format_selected_days(days) do
    count = length(days)

    if count == 7 do
      "All days"
    else
      "#{count} day#{if count == 1, do: "", else: "s"} selected"
    end
  end
end
