defmodule NooraStorybookWeb.Router do
  use NooraStorybookWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {NooraStorybookWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", NooraStorybookWeb do
    pipe_through(:browser)
  end

  # Other scopes may use custom stacks.
  # scope "/api", NooraStorybookWeb do
  #   pipe_through :api
  # end
end
