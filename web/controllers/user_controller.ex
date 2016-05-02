defmodule Discovery.UserController do
  use Discovery.Web, :controller

  alias Discovery.User
  alias Discovery.Company

  plug :authenticate_user when action in [:index, :show]
  plug :access_user when action in [:edit, :update, :delete]

  def index(conn, _params) do
    users = 
    Repo.all(User)
    |> Repo.preload(:company)
    
    render conn, "index.html", users: users
  end

  def new(conn, %{"unique_company_id" => unique_company_id}) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", unique_company_id: unique_company_id, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    # User is already in DB from invitation - Find them
    user = Repo.get_by!(User, email: user_params["email"])
    # Get the registration changeset from that user and cast the params submitted
    changeset = User.registration_changeset(user, user_params)
    |> Ecto.Changeset.put_change(:auth_id, "")

    company = Repo.get_by!(Company, unique_id: user_params["unique_company_id"])

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> Discovery.Auth.login(user)
        |> put_flash(:info, "Welcome #{user.first_name} #{user.last_name}!")
        |> redirect(to: company_path(conn, :join_company, company: company))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, unique_company_id: user_params["unique_company_id"])
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

  def reset(conn, _params) do
    render(conn, "reset.html")
  end

  def new_password(conn, %{"auth_id" => auth_id}) do
    render(conn, "update.html", auth_id: auth_id)
  end

  def update_password(conn, %{"update_form" => update_params}) do
    # find user by auth_id
    user = Repo.get_by(User, auth_id: update_params["auth_id"])
    # Pass the password to the update_changeset
    |> User.update_changeset(update_params)
    #update the user with the new password
    case Repo.update(user) do
      {:ok, user} ->
        # Remove the auth_id
        
        Repo.update(Ecto.Changeset.change(user, auth_id: ""))
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> redirect(to: ticket_path(conn, :index))
      {:error, changeset} ->
        render(conn, "update.html", auth_id: update_params["auth_id"], changeset: changeset)
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
  # redirects any user who didnt get the email and may have accidentally got to this url
  def new_redirect(conn, _params) do
    conn
    |> put_flash(:error, "You must be invited before you can create an account. Please contact support or your organizational leader for help")
    |> redirect(to: page_path(conn, :index))
  end
end
