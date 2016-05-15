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
    # Sessions is our login controller:o
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  # Unauthenticated user actions
  scope "/users", Discovery do
    pipe_through [:browser]

    # Password Reset
    get "/reset", UserController, :reset
    post "/reset", EmailController, :reset
    get "/reset/:auth_id", UserController, :new_password
    post "/reset/update", UserController, :update_password
  end

  scope "/users", Discovery do
    pipe_through [:browser, :authenticated_not_allowed]
    # Create a user
    get "/new", UserController, :new_redirect # Graceful fallback
    get "/new/:unique_company_id", UserController, :new_redirect # Graceful fallback
    get "/new/:unique_company_id/:token", UserController, :new
    post "/", UserController, :create
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
    # get "/join", CompanyController, :join
    get "/join", CompanyController, :join_company
    get "/github_link", CompanyController, :github_link
    resources "/", CompanyController, except: [:join, :github_link]
  end

# Random Authenticated Routes
scope "/", Discovery do
  pipe_through [:browser, :authenticate_user]

  post "/invite/:company", EmailController, :invite # Sends email for invitation
end
  
  # Tickets router + middleware
  scope "/tickets", Discovery do
    pipe_through [:browser, :authenticate_user]
    get "/:id/export", TicketController, :export
    get "/:id/github_export", TicketController, :github_export
    resources "/", TicketController, except: [:export, :github_export]
  end
end
