defmodule Discovery.UserController do
  use Discovery.Web, :controller

  alias Discovery.User

  plug :authenticate_user when action in [:index, :show]

  def index(conn, _params) do
    users = 
    Repo.all(User)
    |> Repo.preload(:company)
    
    render conn, "index.html", users: users
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Discovery.Auth.login(user)
        |> put_flash(:info, "Welcome #{user.first_name} #{user.last_name}!")
        |> redirect(to: company_path(conn, :new))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = 
    Repo.get!(User, id)
    |> Repo.preload(:company)

    # We have to check for nil here before doing any sort of query
    # Its an elixir/phoenix thing.
    if is_nil(user.company_id) do
      # If the user doesnt have a company id
      # we can throw in anything into the view to be rendered to @company in the template
      conn
        |> assign(:company, "None")
        |> render("show.html", user: user)
    else
      # We found a user with a company and want to return the company name to the template
      company = Repo.get_by(Discovery.Company, id: user.company_id)
      conn 
        |> assign(:company, company)
        |> render("show.html", user: user)
    end
  end

  def edit(conn, %{"id" => id}) do
    case self_access_only(conn, id) do
      {:ok, conn} -> 
        user = Repo.get!(User, id)
        changeset = User.changeset(user)
        render(conn, "edit.html", user: user, changeset: changeset)
      {:error, conn} -> 
        conn
        |> put_flash(:error, "Error, You do not have access this page")
        |> redirect(to: user_path(conn, :index))
        |> halt()
    end

  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    case self_access_only(conn, id) do
      {:ok, conn} ->
        user = Repo.get!(User, id)
        changeset = User.update_changeset(user, user_params)

        case Repo.update(changeset) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User updated successfully.")
            |> redirect(to: user_path(conn, :show, user))
          {:error, changeset} ->
            render(conn, "edit.html", user: user, changeset: changeset)
        end
      {:error, conn} -> 
        conn
        |> put_flash(:error, "Error, You do not have access this page")
        |> redirect(to: user_path(conn, :index))
        |> halt()
    end
  end

  def delete(conn, %{"id" => id}) do
    case self_access_only(conn, id) do
      {:ok, conn} ->
        user = Repo.get!(User, id)

        # Here we use delete! (with a bang) because we expect
        # it to always work (and if it does not, it will raise).
        Repo.delete!(user)

        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, conn} ->
        conn
        |> put_flash(:error, "Error, You do not have access this page")
        |> redirect(to: user_path(conn, :index))
        |> halt()
    end
  end

  # This only allows the specific user access to updated/delete their profile
  def self_access_only(conn, id) do
    # Compare the current user to the id from the path
    if to_string(conn.assigns.current_user.id) == id do
      {:ok, conn}
    else
      {:error, conn}
    end
  end
end
