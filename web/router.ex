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

    get "/", PageController, :index
    # Password Reset
    get "/users/reset", UserController, :reset
    post "/users/reset", EmailController, :reset
    get "/users/reset/:auth_id", UserController, :new_password
    post "/users/reset/update", UserController, :update_password
    # Sessions is our login controller:o
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

# Random Authenticated Routes
scope "/", Discovery do
  pipe_through [:browser, :authenticate_user]

  get "/invite/:company", EmailController, :invite # Sends email for invitation
end
  
  # Tickets router + middleware
  scope "/tickets", Discovery do
    pipe_through [:browser, :authenticate_user]
    resources "/", TicketController
  end
end
