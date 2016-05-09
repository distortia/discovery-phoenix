defmodule Discovery.AuthTest do
  use Discovery.ConnCase
  alias Discovery.Auth 

  @valid_user %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "Val1dP@ass", role: "User", auth_id: "123"}

  setup %{conn: conn} do
    conn =
      conn
      # Pass conn through a Router and pipelines while bypassing route dispatch.
      |> bypass_through(Discovery.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "Login", %{conn: conn} do
    login_conn =
    conn
    |> Auth.login(%Discovery.User{id: 123})
    |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "Login by email and pass", %{conn: conn} do
    user = insert_user(@valid_user)
    {:ok, conn} = Auth.login_by_email_and_pass(conn, "testuser@test.com", "Val1dP@ass", repo: Repo)
    assert conn.assigns.current_user.id == user.id
  end

  test "login with invalid email", %{conn: conn} do
    assert {:error, :not_found, _conn} = Auth.login_by_email_and_pass(conn, "testuser@test.com", "Val1dP@ass", repo: Repo)
  end

  test "login with invalid password", %{conn: conn} do
    insert_user(@valid_user)
    assert {:error, :unauthorized, conn} == Auth.login_by_email_and_pass(conn, "testuser@test.com", "invalid", repo: Repo)
  end

  @tags login_as: "unittest@unittest.com"
  test "logout", %{conn: conn} do
    logout_conn =
    conn
    |> put_session(:user_id, 123)
    |> Auth.logout()
    |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "Authenticate user" do
    conn =
    conn
    |> assign(:current_user, %Discovery.User{})
    |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "Authenticate user when current user not logged in", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end 

  @tags login_as: "unittest@unittest.com"
  test "Authenticated not allowed - while logged in" do
    conn =
    conn
    |> assign(:current_user, %Discovery.User{})
    |> Auth.authenticate_user([])
    |> Auth.authenticated_not_allowed([])
    assert redirected_to(conn) == ticket_path(conn, :index)
    assert conn.halted
  end  

  @tags login_as: "unittest@unittest.com"
  test "Authenticated not allowed - while not logged in" do
    conn =
    conn
    |> assign(:current_user, %Discovery.User{})
    |> Auth.authenticated_not_allowed([])
    assert conn.halted
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn =
    conn
    |> put_session(:user_id, user.id)
    |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end
end