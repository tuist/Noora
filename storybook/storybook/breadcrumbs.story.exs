defmodule TuistWeb.Storybook.Breadcrumbs do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Noora.Breadcrumbs

  def function, do: &Breadcrumbs.breadcrumbs/1

  def imports, do: [{Breadcrumbs, [breadcrumb: 1, breadcrumb_item: 1]}, {Noora.Icon, [smart_home: 1]}]

  def variations do
    [
      %Variation{
        id: :with_slashes,
        attributes: %{
          label: "Breadcrumbs"
        },
        slots: [
          """
          <.breadcrumb id="account-breadcrumb" label="tuist">
            <:icon><.smart_home /></:icon>
            <.breadcrumb_item id="account-breadcrumb-1" value="1" label="Item 1" />
            <.breadcrumb_item id="account-breadcrumb-1" value="2" label="Item 2" selected={true} />
          </.breadcrumb>
          <.breadcrumb id="project-breadcrumb" label="tuist">
            <.breadcrumb_item id="project-breadcrumb-1" value="1" label="Item 1" />
          </.breadcrumb>
          """
        ]
      },
      %Variation{
        id: :with_arrows,
        attributes: %{
          label: "Breadcrumbs",
          style: "arrow"
        },
        slots: [
          """
          <.breadcrumb id="account-breadcrumb" label="tuist">
            <:icon><.smart_home /></:icon>
            <.breadcrumb_item value="1" label="Item 1" />
            <.breadcrumb_item value="2" label="Item 2" selected={true} />
          </.breadcrumb>
          <.breadcrumb id="project-breadcrumb" label="tuist">
            <.breadcrumb_item value="1" label="Item 1" />
          </.breadcrumb>
          """
        ]
      },
      %Variation{
        id: :with_avatar,
        attributes: %{
          label: "Breadcrumbs"
        },
        slots: [
          """
          <.breadcrumb id="with-avatar" label="tuist" show_avatar>
            <:icon><.smart_home /></:icon>
            <.breadcrumb_item id="with-avatar-breadcrumb-1" value="1" label="Item 1" show_avatar />
            <.breadcrumb_item id="with-avatar-breadcrumb-1" value="2" label="Item 2" show_avatar selected={true} />
          </.breadcrumb>
          <.breadcrumb id="project-breadcrumb" label="tuist">
            <.breadcrumb_item id="project-with-avatar-breadcrumb-1" value="1" label="Item 1" />
          </.breadcrumb>
          """
        ]
      },
      %Variation{
        id: :without_dropdown,
        attributes: %{style: "arrow"},
        slots: [
          """
          <.breadcrumb id="with-avatar" label="tuist" />
          <.breadcrumb id="project-breadcrumb" label="tuist" />
          """
        ]
      }
    ]
  end
end
