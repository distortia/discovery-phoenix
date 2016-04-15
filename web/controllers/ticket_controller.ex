defmodule Discovery.TicketController do
  use Discovery.Web, :controller

  alias Discovery.Ticket

  plug :scrub_params, "ticket" when action in [:create, :update]

  # This Action assigns the current user to the connection
  # Allowing us to pass the user to different controllers and routes
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
    changeset = 
    user
    |> build_assoc(:tickets)
    |> Ticket.changeset()
  end

  # We pass in the user as a param of the new ticket process
  def create(conn, %{"ticket" => ticket_params}, user) do
    changeset =
    user
    |> build_assoc(:tickets)
    |> Ticket.changeset(ticket_params)
    # Check for the :ok tuple from inserting into the DB
    # If :ok -> All is good
    # IF :error -> Render new ticket page with form errors
    case Repo.insert(changeset) do
      {:ok, _ticket} ->
        conn
        |> put_flash(:info, "Ticket created successfully")
        |> redirect(to: ticket_path(conn, :index))
      {:error, changeset} -> 
        render(conn, "new.html", changeset: changeset)
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
    render(conn, "edit.html", ticket: ticket, changeset: changeset)
  end

  # Same deal as Discovery.Ticket.Create/3
  def update(conn, %{"id" => id, "ticket" => ticket_params}, user) do
    ticket = Repo.get!(user_tickets(user), id)
    changeset = Ticket.changeset(ticket, ticket_params)

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
    ticket = Repo.get_by!(user_tickets(user), id)
    Repo.delete!(ticket)

    conn
    |> put_flash(:info, "Ticket Deleted!")
    |> redirect(to: ticket_path(conn, :index))
  end
  # Function to look up tickets for the given user
  defp user_tickets(user) do
    assoc(user, :tickets)
  end
end
