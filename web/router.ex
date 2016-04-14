defmodule Discovery.Router do
  use Discovery.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Discovery.Auth, repo: Discovery.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Discovery do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/companies", CompanyController
    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/tickets", TicketController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Discovery do
  #   pipe_through :api
  # end
end
