defmodule Discovery.TicketControllerTest do
  use Discovery.ConnCase

  alias Discovery.Ticket

  @valid_attrs %{title: "Ticket title", body: "ticket body", assigned_to: "#{1}"}
  @valid_attrs_with_nil_tags %{title: "Ticket title", body: "ticket body", assigned_to: "#{1}", tags: nil}
  @invalid_attrs %{title: "invalid"}

  # Get the count of all the tickets in the db
  defp ticket_count(query), do: Repo.one(from v in query, select: count(v.id))

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      company = insert_company()
      {:ok, user} = 
      insert_user(email: "unittest@unittest.com", first_name: "unit", last_name: "test", password: "Val1dP@ass")
      |> join_company(company)
      conn = assign(conn(), :current_user, user)
      {:ok, conn: conn, user: user, company: company}
    else
      :ok
    end
  end

  @tag login_as: "unittest@unittest.com"
  test "GET /tickets will show tickets for the user", %{conn: conn, user: user} do
    ticket  = insert_ticket(user, title: "unit test ticket", body: "unit test body", assigned_to: "#{user.id}")
    other_ticket = insert_ticket(insert_user(email: "otherunittest@unittest.com"), title: "another ticket", body: "mticket", assigned_to: "1")

    conn = get conn, ticket_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing tickets/
    assert String.contains?(conn.resp_body, ticket.title)
    refute String.contains?(conn.resp_body, other_ticket.title)
  end

  @tag login_as: "unittest@unittest.com"
  test "Create ticket and redirect - assigned to self", %{conn: conn, user: user} do
    ticket_params = %{title: "Ticket title", body: "ticket body", assigned_to: "#{user.id}"}
    conn = post conn, ticket_path(conn, :create), ticket: ticket_params, user: user
    assert redirected_to(conn) == ticket_path(conn, :index)
    assert  get_flash(conn, :info) == "Ticket created successfully"
    assert Repo.get_by!(Ticket, ticket_params).user_id == user.id
  end

  @tag login_as: "unittest@unittest.com"
  test "Create ticket and redirect - assigned to another user", %{conn: conn, user: user} do
    other_user = insert_user(email: "other@user.com")
    ticket_params = %{title: "Ticket title", body: "ticket body", assigned_to: "#{other_user.id}"}
    conn = post conn, ticket_path(conn, :create), ticket: ticket_params, user: "unittest@unittest.com"
    assert redirected_to(conn) == ticket_path(conn, :index)
    assert  get_flash(conn, :info) == "Ticket created successfully"
    assert Repo.get_by!(Ticket, ticket_params).user_id == other_user.id
  end

  @tag login_as: "unittest@unittest.com"
  test "Does not create ticket and renders errors when invalid", %{conn: conn, user: user} do
    count_before = ticket_count(Ticket)
    conn = post conn, ticket_path(conn, :create), ticket: %{title: "invalid", assigned_to: user.id, tags: []}, user: user
    assert html_response(conn, 200) =~ "check the errors"
    assert ticket_count(Ticket) == count_before
  end

  test "Redirect from /tickets to index with error when not logged in", %{conn: conn} do
    Enum.each([
      get(conn, company_path(conn, :index)),
      get(conn, company_path(conn, :show, "1")),
      get(conn, company_path(conn, :new)),
      get(conn, company_path(conn, :edit, "1")),
      put(conn, company_path(conn, :update, "1", %{})),
      delete(conn, company_path(conn, :delete, "1")),
      ], fn conn -> 
       assert redirected_to(conn, 302) =~ "/sessions/new"
       assert get_flash(conn, :error) == "Error, You must be logged in to access this page"
     end)
  end

  @tag login_as: "unittest@unittest.com"
  test "New Ticket view when logged in", %{conn: conn, user: user} do
    conn = get conn, ticket_path(conn, :new), user: user
    assert html_response(conn, 200) =~ "New ticket"
  end

  @tag login_as: "unittest@unittest.com"
  test "Show ticket view when logged in", %{conn: conn, user: user} do
    ticket = insert_ticket(user, @valid_attrs)
    conn = get conn, ticket_path(conn, :show, ticket.id), user: user
    assert html_response(conn, 200) =~ "Show ticket"
    assert html_response(conn, 200) =~ @valid_attrs.title
  end  

  @tag login_as: "unittest@unittest.com"
  test "Edit ticket view when logged in", %{conn: conn, user: user} do
    ticket = insert_ticket(user, @valid_attrs)
    conn = get conn, ticket_path(conn, :edit, ticket.id), user: user
    assert html_response(conn, 200) =~ "Edit ticket"
    assert html_response(conn, 200) =~ @valid_attrs.title
  end

  @tag login_as: "unittest@unittest.com"
  test "Update ticket view when logged in", %{conn: conn, user: user} do
    ticket = insert_ticket(user, @valid_attrs)
    updates = %{"ticket" => %{title: "Updated title"}}
    conn = put conn, ticket_path(conn, :update, ticket.id, updates), user: user
    assert get_flash(conn, :info) == "Ticket updated successfully"
    assert redirected_to(conn, 302) == ticket_path(conn, :index)
  end  

  @tag login_as: "unittest@unittest.com"
  test "Update ticket view when logged in - invalid changeset", %{conn: conn, user: user} do
    ticket = insert_ticket(user, @valid_attrs)
    updates = %{"ticket" => %{title: ""}}
    conn = put conn, ticket_path(conn, :update, ticket.id, updates), user: user
    assert html_response(conn, 200) =~ "Oops, something went wrong! Please check the errors below."
  end  

  @tag login_as: "unittest@unittest.com"
  test "Update ticket view when logged in - new user", %{conn: conn, user: user} do
    ticket = insert_ticket(user, @valid_attrs)
    other_user = insert_user(email: "other@user.com")
    updates = %{"ticket" => %{assigned_to: other_user.id}}
    conn = put conn, ticket_path(conn, :update, ticket.id, updates), user: user
    assert get_flash(conn, :info) == "Ticket updated successfully"
    assert redirected_to(conn, 302) == ticket_path(conn, :index)
  end

  @tag login_as: "unittest@unittest.com"
  test "Delete ticket view when logged in", %{conn: conn, user: user} do
    count_before = ticket_count(Ticket)
    ticket = insert_ticket(user, @valid_attrs)
    conn = delete conn, ticket_path(conn, :delete, ticket.id), user: user
    assert ticket_count(Ticket) == count_before
    assert get_flash(conn, :info) == "Ticket Deleted!"
    assert redirected_to(conn, 302) == ticket_path(conn, :index)
  end
end
