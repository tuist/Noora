defmodule Noora.Toast do
  use Phoenix.Component

  @enforce_keys [:id, :status, :title, :description]
  defstruct [:id, :status, :title, :description]

  attr(:corner, :atom,
    values: [:top_left, :top_center, :top_right, :bottom_left, :bottom_center, :bottom_right],
    default: :top_right,
    doc: "The corner where the toaster should be displayed"
  )

  attr(:rest, :global)

  def toaster(assigns) do
    socket = Map.get(assigns[:rest], :socket)
    connected? = not is_nil(socket) && Phoenix.LiveView.connected?(socket)

    assigns =
      assigns
      |> assign(
        :connected?,
        connected?
      )
      |> assign(:toasts, [
        %__MODULE__{
          id: UUIDv7.generate(),
          status: "info",
          title: "Toast",
          description: "This works as expected"
        }
      ])
      |> assign(:id, Map.get(assigns, :id, UUIDv7.generate()))

    ~H"""
    <div class="noora-toaster" id={@id} data-corner={Atom.to_string(@corner)}>
      <%= if @connected? do %>
        <.live_component module={__MODULE__.LiveComponent} toasts={@toasts} connected?={@connected?} />
      <% else %>
        <__MODULE__.toasts toasts={@toasts} connected?={@connected?} />
      <% end %>
    </div>
    """
  end

  attr(:toasts, :list, required: false)
  attr(:connected?, :boolean, default: false)

  defp toasts(assigns) do
    ~H"""
    <Noora.Alert.alert
      :for={toast <- @toasts}
      id={"toast-#{toast.id}"}
      status={toast.status}
      title={toast.title}
      size={toast.size}
      description={@metadata.description}
      dismissible
      phx-click={!@connected? && Phoenix.LiveView.JS.hide()}
    />
    """
  end

  # # LiveComponent for LiveView integration
  defmodule LiveComponent do
    @moduledoc false
    use Phoenix.LiveComponent

    @impl Phoenix.LiveComponent
    def mount(socket) do
      # socket =
      #   socket
      #   |> stream_configure(:toasts,
      #     dom_id: fn %Toast{id: id} ->
      #       "toast-#{id}"
      #     end
      #   )
      #   |> stream(:toasts, [])
      #   |> assign(:toast_count, 0)

      {:ok, socket}
    end

    @impl Phoenix.LiveComponent
    def update(assigns, socket) do
      # {toast, assigns} = Map.pop(assigns, :toast)

      # socket =
      #   socket
      #   |> assign(assigns)

      {:ok, socket}
    end

    @impl Phoenix.LiveComponent
    def handle_info({:new_toast, toast}, socket) do
      {:noreply, socket}
    end

    @impl Phoenix.LiveComponent
    def render(assigns) do
      ~H"""
      <Noora.Toast.toaster toasts={@toasts} />
      """
    end
  end
end
