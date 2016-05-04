defmodule Discovery.CompanyController do
  use Discovery.Web, :controller

  alias Discovery.Company

  plug :scrub_params, "company" when action in [:create, :update]
  plug :user_in_company when action in [:show, :update, :delete, :edit]

  #Temporary plug to prevent access to view all companies
  plug :access_all_companies when action in [:index]

  # This Action assigns the current user to the connection
  # Allowing us to pass the user to different controllers and routes
  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    companies = Repo.all(Company)
    render(conn, "index.html", companies: companies)
  end

  def new(conn, _params, user) do
    changeset = Company.changeset(%Company{})
    # Need to get the company and build association with the user
    # changeset = 
    # company
    # |> build_assoc(:user)
    # |> Company.changeset(company_params)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"company" => company_params}, user) do
    # Original Changeset
    changeset = Company.changeset(%Company{}, company_params)
    |> Ecto.Changeset.put_change(:unique_id, Discovery.EmailController.random_string(10))

    case Repo.insert(changeset) do
      {:ok, company} ->
        conn
        |> put_flash(:info, "Company created successfully.")
        |> redirect(to: company_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    company = 
    Repo.get!(Company, id)
    |> Repo.preload(:users)

    tickets =
      # Enum.map returns a list of tickets(which happen to be lists, thats why we flatten at the end)
      # http://elixir-lang.org/docs/stable/elixir/Enum.html - # TODO: The Dict example may be a better fit for us
      Enum.map company.users, fn(user) -> 
        user = Repo.preload(user, :tickets)
        user.tickets
       end
     tickets = List.flatten(tickets)
    # I passed users/tickets as their own thing to the view for ease of use
    render(conn, "show.html", company: company, users: company.users, tickets: tickets)
  end

  def edit(conn, %{"id" => id}, user) do
    company = Repo.get!(Company, id)
    changeset = Company.changeset(company)
    render(conn, "edit.html", company: company, changeset: changeset)
  end

  def update(conn, %{"id" => id, "company" => company_params}, user) do
    company = Repo.get!(Company, id)
    changeset = nil
    if company_params["tag"] do
      new_tags = List.insert_at(company.company_tags, length(company.company_tags), to_string(company_params["tag"]))
      new_params = %{"name" => to_string(company_params["name"]), "company_tags" => new_tags}
      changeset = Company.changeset(company, new_params)
    else
      changeset = Company.changeset(company, company_params)
    end

    case Repo.update(changeset) do
      {:ok, company} ->
        conn
        |> put_flash(:info, "Company updated successfully.")
        |> redirect(to: company_path(conn, :show, company))
      {:error, changeset} ->
        render(conn, "edit.html", company: company, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    company = Repo.get!(Company, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(company)

    conn
    |> put_flash(:info, "Company deleted successfully.")
    |> redirect(to: company_path(conn, :index))
  end

  def join(conn, _placeholder, user) do
    changeset = Company.changeset(%Company{})
    render(conn, "join.html", changeset: changeset, user: user)
  end


  def join_company(conn, %{"company" => company_id}, user) do 
    user = Repo.preload(user, :company)

    company = 
      Repo.get!(Company, company_id)
      |> Ecto.build_assoc(:users, Map.from_struct user)

    case Repo.update(company) do
      {:ok, _company} ->
        conn
        |> put_flash(:info, "Company joined successfully")
        |> redirect(to: ticket_path(conn, :index), user: user)
      {:error, changeset} -> 
        render(conn, "join.html", changeset: changeset)
    end
  end
  # Function to look up users for the given company
  defp company_users(company) do
    assoc(company, :users)
  end

  defp user_company(user) do
    assoc(user, :company)
  end

  def user_in_company(conn, _opts) do
    if conn.params["id"] == to_string(conn.assigns.current_user.company_id) do
      conn
    else
      conn
       |> put_flash(:error, "Error, You do not have access do this")
       |> redirect(to: user_path(conn, :index))
       |> halt()  
    end
  end

  #For now, no regular user has access to view all of the companies
  def access_all_companies(conn, _opts) do
    if(to_string(conn.assigns.current_user.role) == "God") do
      conn
    else
      conn
       |> put_flash(:error, "Error, You do not have access do this")
       |> redirect(to: Discovery.Router.Helpers.page_path(conn, :index))
       |> halt()  
    end
  end

end
