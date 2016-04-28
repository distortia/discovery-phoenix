defmodule Discovery.TicketControllerTest do
  use Discovery.ConnCase

  alias Discovery.Ticket

  @valid_attrs %{title: "Ticket title", body: "ticket body", assigned_to: "#{1}"}
  @invalid_attrs %{title: "invalid"}

  # Get the count of all the tickets in the db
  defp ticket_count(query), do: Repo.one(from v in query, select: count(v.id))

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: "unittest@unittest.com", first_name: "unit", last_name: "test", password: "123123")
      conn = assign(conn(), :current_user, user)
      {:ok, conn: conn, user: user}
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
  test "Create ticket and redirect", %{conn: conn, user: user} do
    conn = post conn, ticket_path(conn, :create), ticket: @valid_attrs
    assert redirected_to(conn) == ticket_path(conn, :index)
    assert Repo.get_by!(Ticket, @valid_attrs).user_id == user.id
  end

  @tag login_as: "unittest@unittest.com"
  test "Does not create ticket and renders errors when invalid", %{conn: conn, user: user} do
    count_before = ticket_count(Ticket)
    conn = post conn, ticket_path(conn, :create), ticket: @invalid_attrs
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
end
