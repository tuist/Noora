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
    socket = Map.get(assigns, :socket)
    connected? = not is_nil(socket) and Phoenix.LiveView.connected?(socket)

    assigns =
      assigns
      |> assign(:connected?, connected?)
      |> assign(:toasts, [
        %__MODULE__{
          id: UUIDv7.generate(),
          status: "success",
          title: "Toast",
          description: "This works as expected"
        },
        %__MODULE__{
          id: UUIDv7.generate(),
          status: "success",
          title: "Toast2",
          description: "This works as expected"
        }
      ])
      |> assign(:id, Map.get(assigns, :id, UUIDv7.generate()))

    ~H"""
    <div class="noora-toaster" id={@id} data-corner={Atom.to_string(@corner)}>
      <%= if @connected? do %>
        <.live_component module={__MODULE__.LiveComponent} id="toaster-live-component" />
      <% else %>
        <.toasts toasts={@toasts} connected?={@connected?} />
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
      size="large"
      status={toast.status}
      title={toast.title}
      description={toast.description}
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
      socket =
        socket
        |> assign(:toasts, [
          %Noora.Toast{
            id: UUIDv7.generate(),
            status: "success",
            title: "Toast",
            description: "This works as expected"
          }
        ])
        |> assign(:connected?, true)

      {:ok, socket}
    end

    @impl Phoenix.LiveComponent
    def update(assigns, socket) do
      {:ok, assign(socket, assigns)}
    end

    def handle_info({:new_toast, _toast}, socket) do
      {:noreply, socket}
    end

    @impl Phoenix.LiveComponent
    def render(assigns) do
      ~H"""
      LiveView
      <Noora.Alert.alert
        :for={toast <- @toasts}
        id={"toast-#{toast.id}"}
        size="large"
        status={toast.status}
        title={toast.title}
        description={toast.description}
        dismissible
        phx-click={!@connected? && Phoenix.LiveView.JS.hide()}
      />
      """
    end
  end
end
