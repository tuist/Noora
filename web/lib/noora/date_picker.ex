defmodule Noora.DatePicker do
  @moduledoc """
  A date range picker component with preset options and custom selection.

  Built on top of Zag.js date picker machine, this component supports:
  - Predefined range presets (Last 7 days, Last 30 days, etc.) with DateTime precision
  - Custom date range selection via calendar
  - Desktop layout (sidebar presets + two-month calendar) and mobile layout (tabs + single-month calendar)
  - Light/dark mode theming

  ## Example

  ```elixir
  <.date_picker
    id="date-range"
    name="date_range"
    on_value_change="date_range_changed"
  />
  ```

  ## Custom presets

  ```elixir
  <.date_picker
    id="date-range"
    name="date_range"
    on_value_change="date_range_changed"
    presets={[
      %{id: "1h", label: "Last 1 hour", duration: {1, :hour}},
      %{id: "7d", label: "Last 7 days", duration: {7, :day}},
      %{id: "30d", label: "Last 30 days", duration: {30, :day}},
      %{id: "custom", label: "Custom"}
    ]}
  />
  ```

  ## Handling value changes

  ```elixir
  def handle_event("date_range_changed", %{"value" => %{"start" => start, "end" => end_dt}, "preset" => preset}, socket) do
    # start and end_dt are ISO8601 DateTime strings
    {:noreply, assign(socket, :date_range, %{start: start, end: end_dt})}
  end
  ```
  """
  use Phoenix.Component

  import Noora.Icon

  @default_presets [
    %{id: "1h", label: "Last 1 hour", duration: {1, :hour}},
    %{id: "24h", label: "Last 24 hours", duration: {24, :hour}},
    %{id: "7d", label: "Last 7 days", duration: {7, :day}},
    %{id: "30d", label: "Last 30 days", duration: {30, :day}},
    %{id: "3m", label: "Last 3 months", duration: {3, :month}},
    %{id: "6m", label: "Last 6 months", duration: {6, :month}},
    %{id: "12m", label: "Last 12 months", duration: {12, :month}},
    %{id: "custom", label: "Custom", duration: nil}
  ]

  @doc """
  Returns the default presets for the date picker.
  """
  def default_presets, do: @default_presets

  attr :id, :string, required: true, doc: "Unique identifier for the date picker component"

  attr :label, :string, default: "Select date range", doc: "Label displayed on the trigger button"

  attr :name, :string, default: nil, doc: "The name attribute for the hidden input field"

  attr :value, :map,
    default: nil,
    doc: "The currently selected range as a map with :start and :end DateTime keys"

  attr :presets, :list,
    default: nil,
    doc:
      "List of preset options. Each preset is a map with :id, :label, and optional :duration keys. Duration is a tuple of {amount, unit} where unit is :hour, :day, :week, :month, or :year"

  attr :selected_preset, :string, default: nil, doc: "The ID of the currently selected preset"

  attr :min, :any,
    default: nil,
    doc: "Minimum selectable date (Date, DateTime, or ISO8601 string)"

  attr :max, :any,
    default: nil,
    doc: "Maximum selectable date (Date, DateTime, or ISO8601 string)"

  attr :locale, :string, default: "en-US", doc: "BCP 47 language tag for date formatting"

  attr :start_of_week, :integer,
    default: 0,
    doc: "The day the week starts on (0 = Sunday, 1 = Monday, etc.)"

  attr :disabled, :boolean, default: false, doc: "Whether the date picker is disabled"

  attr :on_value_change, :string,
    default: nil,
    doc: "Event handler name for when the selected date range changes"

  attr :on_cancel, :string,
    default: nil,
    doc: "Event handler name for when the cancel button is clicked"

  attr :rest, :global, doc: "Additional HTML attributes"

  def date_picker(assigns) do
    presets = assigns[:presets] || @default_presets

    assigns =
      assigns
      |> assign(:presets, presets)
      |> assign_new(:presets_json, fn ->
        presets
        |> Enum.map(fn preset ->
          %{
            id: preset.id,
            label: preset.label,
            duration: encode_duration(Map.get(preset, :duration))
          }
        end)
        |> Jason.encode!()
      end)
      |> assign_new(:trigger_label, fn ->
        selected_preset = assigns[:selected_preset]

        if selected_preset do
          preset = Enum.find(presets, &(&1.id == selected_preset))
          if preset, do: preset.label, else: assigns[:label] || "Select date range"
        else
          assigns[:label] || "Select date range"
        end
      end)

    ~H"""
    <div
      id={@id}
      class="noora-date-picker"
      phx-hook="NooraDatePicker"
      data-name={@name}
      data-locale={@locale}
      data-start-of-week={@start_of_week}
      data-min={encode_date(@min)}
      data-max={encode_date(@max)}
      data-presets={@presets_json}
      data-selected-preset={@selected_preset}
      data-on-value-change={@on_value_change}
      data-on-cancel={@on_cancel}
      data-disabled={@disabled}
      {@rest}
    >
      <div data-part="control">
        <button data-part="trigger" type="button" disabled={@disabled}>
          <span data-part="trigger-label">{@trigger_label}</span>
          <div data-part="trigger-icon">
            <.calendar_week />
          </div>
        </button>
      </div>

      <div data-part="positioner">
        <div data-part="content">
          <!-- Desktop: Sidebar presets -->
          <div data-part="presets" data-device="desktop">
            <button
              :for={preset <- @presets}
              type="button"
              data-part="preset-item"
              data-preset-id={preset.id}
              data-selected={@selected_preset == preset.id}
              disabled={@disabled}
            >
              {preset.label}
            </button>
          </div>
          
    <!-- Calendar area -->
          <div data-part="calendar">
            <!-- Mobile: Tab presets -->
            <div data-part="presets" data-device="mobile">
              <button
                :for={preset <- @presets}
                type="button"
                data-part="preset-item"
                data-preset-id={preset.id}
                data-selected={@selected_preset == preset.id}
                disabled={@disabled}
              >
                {preset.label}
              </button>
            </div>

            <div data-part="months">
              <!-- Month 1 -->
              <div data-part="month" data-index="0">
                <div data-part="view-control">
                  <button type="button" data-part="prev-trigger" disabled={@disabled}>
                    <.chevron_left />
                  </button>
                  <span data-part="view-trigger"></span>
                  <button type="button" data-part="next-trigger" disabled={@disabled}>
                    <.chevron_right />
                  </button>
                </div>
                <table data-part="table">
                  <thead data-part="table-head">
                    <tr data-part="table-row">
                      <th :for={_day <- 1..7} data-part="table-header"></th>
                    </tr>
                  </thead>
                  <tbody data-part="table-body">
                    <tr :for={_week <- 1..6} data-part="table-row">
                      <td :for={_day <- 1..7} data-part="day-table-cell">
                        <button type="button" data-part="day-table-cell-trigger" disabled={@disabled}>
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              
    <!-- Month 2 (Desktop only) -->
              <div data-part="month" data-index="1" data-desktop-only>
                <div data-part="view-control">
                  <button type="button" data-part="prev-trigger" disabled={@disabled}>
                    <.chevron_left />
                  </button>
                  <span data-part="view-trigger"></span>
                  <button type="button" data-part="next-trigger" disabled={@disabled}>
                    <.chevron_right />
                  </button>
                </div>
                <table data-part="table">
                  <thead data-part="table-head">
                    <tr data-part="table-row">
                      <th :for={_day <- 1..7} data-part="table-header"></th>
                    </tr>
                  </thead>
                  <tbody data-part="table-body">
                    <tr :for={_week <- 1..6} data-part="table-row">
                      <td :for={_day <- 1..7} data-part="day-table-cell">
                        <button type="button" data-part="day-table-cell-trigger" disabled={@disabled}>
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            
    <!-- Footer -->
            <div data-part="footer">
              <div data-part="range-display">
                <div data-part="date-display" data-type="start">
                  <span data-part="day"></span>
                  <span data-part="date-separator">•</span>
                  <span data-part="month"></span>
                  <span data-part="date-separator">•</span>
                  <span data-part="year"></span>
                </div>
                <div data-part="arrow">
                  <.arrow_right />
                </div>
                <div data-part="date-display" data-type="end">
                  <span data-part="day"></span>
                  <span data-part="date-separator">•</span>
                  <span data-part="month"></span>
                  <span data-part="date-separator">•</span>
                  <span data-part="year"></span>
                </div>
              </div>
              <div data-part="actions">
                <button type="button" data-part="cancel" disabled={@disabled}>
                  Cancel
                </button>
                <button type="button" data-part="apply" disabled={@disabled}>
                  Apply
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp encode_date(nil), do: nil

  defp encode_date(%DateTime{} = dt) do
    DateTime.to_iso8601(dt)
  end

  defp encode_date(%Date{} = d) do
    Date.to_iso8601(d)
  end

  defp encode_date(str) when is_binary(str), do: str

  defp encode_duration(nil), do: nil
  defp encode_duration({amount, unit}), do: %{amount: amount, unit: to_string(unit)}
end
