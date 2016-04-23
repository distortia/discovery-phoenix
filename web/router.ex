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

  scope "/", Discovery do
    pipe_through :browser # Use the default browser stack
    get "/email/:company", PageController, :email

    get "/", PageController, :index
    # Sessions is our login controller
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    # Keep the ability to register open
    resources "/users", UserController, only: [:new, :create]
  end

  # Added scope to the routes for the authentication middleware
  scope "/users", Discovery do
    pipe_through [:browser, :authenticate_user]
    # Lock down the other User functions that should be behind authentication
    resources "/", UserController, except: [:new, :create]
  end
  
  # Companies router + middleware
  scope "/companies", Discovery do
    pipe_through [:browser, :authenticate_user]
    get "/join", CompanyController, :join
    post "/join", CompanyController, :join_company
    resources "/", CompanyController, except: [:join]
  end
  
  # Tickets router + middleware
  scope "/tickets", Discovery do
    pipe_through [:browser, :authenticate_user]
    resources "/", TicketController
  end
end
