defmodule Discovery.UserController do
  use Discovery.Web, :controller

  alias Discovery.User

  plug :authenticate_user when action in [:index, :show]
  plug :access_user when action in [:edit, :update, :delete]

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
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    currentUser = Repo.get!(User, conn.assigns.current_user.id)
    render(conn, "edit.html", user: user, changeset: changeset, currentUser: currentUser)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    # If the user is going to assign a new owner, change their current role to an admin
    if user_params["role"] == "Owner" do
      if change_owner(conn) == {:error, conn} do
        conn
         |> put_flash(:error, "Error Updating User")
         |> redirect(to: user_path(conn, :index))
         |> halt()
      end
    end
    changeset = User.update_changeset(user, user_params)
    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    tickets = Repo.all(assoc(user, :tickets))
    case length(tickets) do
      0 ->
        Repo.delete!(user)
        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: user_path(conn, :index))
      _ ->
        conn
         |> put_flash(:error, "Please re-assign all tickets from this user before deleting")
         |> redirect(to: user_path(conn, :index))
         |> halt()
    end
  end

  #Plug used to determine if the user has access to do an action within the User model space
  def access_user(conn, _options) do
    otherUser = Repo.get!(User, conn.params["id"])
    if to_string(conn.assigns.current_user.id) == conn.params["id"] or conn.assigns.current_user.role == "Owner" or (conn.assigns.current_user.role == "Admin" and otherUser.role != "Owner")  do
      conn
    else
       conn
         |> put_flash(:error, "Error, You do not have access do this")
         |> redirect(to: user_path(conn, :index))
         |> halt()   
    end
  end

  def change_owner(conn) do
    this_user = Repo.get!(User, conn.assigns.current_user.id)
    this_user_params = %{"role" => "Admin"}
    changeset = User.update_owner_changeset(this_user, this_user_params)
    case Repo.update(changeset) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, conn}
    end
  end

end
