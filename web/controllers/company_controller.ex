defmodule Discovery.CompanyController do
  use Discovery.Web, :controller

  alias Discovery.Company

  plug :scrub_params, "company" when action in [:create, :update]

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
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"company" => company_params}, user) do
    changeset = Company.changeset(%Company{}, company_params)
    
    case Repo.insert(changeset) do
      {:ok, _company} ->
        conn
        |> put_flash(:info, "Company created successfully.")
        # TODO: Need to add the association when we create a company to the user
        # |> build_assoc()
        |> redirect(to: company_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    company = Repo.get!(Company, id)
    render(conn, "show.html", company: company)
  end

  def edit(conn, %{"id" => id}, user) do
    company = Repo.get!(Company, id)
    changeset = Company.changeset(company)
    render(conn, "edit.html", company: company, changeset: changeset)
  end

  def update(conn, %{"id" => id, "company" => company_params}, user) do
    company = Repo.get!(Company, id)
    changeset = Company.changeset(company, company_params)

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

  def join_company(conn, %{"company" => company_params}, user) do
   changeset = Company.changeset(%Company{}, company_params)
    # Company_params comes back as a Map in the form %{"name" : "name of company"}
    # Extract the company name from the map
    company_name = Map.get(company_params, "name")
    # We omit the ! in get_by so we don't auto fail when company doesnt exist or could be found
    case Repo.get_by(Company, name: company_name) do
      nil ->
        conn
        |> put_flash(:error, "No company by the name: #{company_name}")
        |> render("join.html", changeset: changeset, user: user)
      _ ->
      conn
      |> put_flash(:info, "Company Joined!")
      # |> build_assoc(:company)
      |> redirect(to: ticket_path(conn, :index))
    end
  end
end
