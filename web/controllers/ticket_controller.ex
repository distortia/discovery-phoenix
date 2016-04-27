defmodule Discovery.TicketController do
  use Discovery.Web, :controller

  alias Discovery.Ticket
  alias Discovery.Company
  alias Discovery.User

  plug :scrub_params, "ticket" when action in [:create, :update]

  # This Action assigns the current user to the connection
  # Allowing us to pass the user to different controllers and routes
  # https://github.com/phoenixframework/phoenix/blob/master/lib/phoenix/controller.ex#L96
  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  # We pass in the user as a param of the index page
  # We find all the tickets for the given user using user_tickets/1
  # Render the ticket index with the tickets for the user
  def index(conn, _params, user) do
    tickets = Repo.all(user_tickets(user))
    render(conn, "index.html", tickets: tickets)
  end

  # We pass in the user as a param of the new ticket process
  # Taking the user and associating them with the ticket
  # Then validating the ticket changeset to make sure the form
  # is filled in properly
  def new(conn, _params, user) do
    # Get the company
    changeset = 
    user
    |> build_assoc(:tickets)
    |> Ticket.changeset()
    render(conn, "new.html", changeset: changeset, users: get_users_from_user_company(user.company_id))
  end

  # We pass in the user as a param of the new ticket process
  # Changeset updates courtesy of 
  # http://stackoverflow.com/questions/33027873/phoenix-framework-how-to-set-default-values-in-ecto-model
  def create(conn, %{"ticket" => ticket_params}, user) do
    changeset =
    Repo.get!(User, ticket_params["assigned_to"])
    |> build_assoc(:tickets)
    |> Ticket.changeset(ticket_params)
    |> Ecto.Changeset.put_change(:created_on, "#{Ecto.DateTime.utc}")
    |> Ecto.Changeset.put_change(:updated_on, "#{Ecto.DateTime.utc}")
    |> Ecto.Changeset.put_change(:created_by, "#{user.first_name} #{user.last_name}")
    |> Ecto.Changeset.put_change(:assigned_to_name,  user_full_name(ticket_params["assigned_to"]))
    
    case Repo.insert(changeset) do
      {:ok, _ticket} ->
        conn
        |> put_flash(:info, "Ticket created successfully")
        |> redirect(to: ticket_path(conn, :index))
      {:error, changeset} -> 
        render(conn, "new.html", changeset: changeset, users: get_users_from_user_company(user.company_id))
    end
  end
  # We pass in the user as a param of the show page
  # We find the specific ticket for the given user using user_tickets/1
  # Render the ticket show view with the ticket specified
  def show(conn, %{"id" => id}, user) do
    ticket = Repo.get!(user_tickets(user), id)
    render(conn, "show.html", ticket: ticket)
  end
  # We pass in the user as a param of the edit page
  # We find the specific ticket for the given user using user_tickets/1
  # Render the ticket edit view with the ticket specified and form changeset
  def edit(conn, %{"id" => id}, user) do
    ticket = Repo.get!(user_tickets(user), id)
    changeset = Ticket.changeset(ticket)
    render(conn, "edit.html", ticket: ticket, changeset: changeset, users: get_users_from_user_company(user.company_id))
  end

  # Same deal as Discovery.Ticket.Create/3
  def update(conn, %{"id" => id, "ticket" => ticket_params}, user) do

    ticket = Repo.get!(user_tickets(user), id)
    changeset = 
      Ticket.changeset(ticket, ticket_params)
      |> Ecto.Changeset.put_change(:updated_on, "#{Ecto.DateTime.utc}")
      |> Ecto.Changeset.put_change(:assigned_to_name, user_full_name(ticket_params["assigned_to"]))

    case Repo.update(changeset) do
      {:ok, _ticket} ->
        conn
        |> put_flash(:info, "Ticket updated successfully")
        |> redirect(to: ticket_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", ticket: ticket, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    ticket = Repo.get!(user_tickets(user), id)
    Repo.delete!(ticket)

    conn
    |> put_flash(:info, "Ticket Deleted!")
    |> redirect(to: ticket_path(conn, :index))
  end

  defp get_users_from_user_company(company_id) do
    Repo.get!(Company, company_id)
    |> company_users()
    |> Repo.all()
    # The select list on the form requires a list of tuples
    # Ex. [{"nick stalter", 1}, {"darrell pappa", 2}]
    |> Map.new(fn(user) -> {user.first_name <> " " <> user.last_name, user.id} end)
  end

  # Returns a string of the first name and last name of the given user id
  defp user_full_name(user_id) do
    name = Repo.get!(User, user_id)
    name = name.first_name <> " " <> name.last_name
  end

  # Function to look up tickets for the given user
  defp user_tickets(user) do
    assoc(user, :tickets)
  end

  defp company_users(company) do
    assoc(company, :users)
  end
end
