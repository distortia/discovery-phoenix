defmodule Discovery.SessionControllerTest do
  use Discovery.ConnCase

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: email, first_name: "unit", last_name: "test", password: "Val1dP@ass")
      conn = assign(conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "GET /session/new", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200) =~ "Welcome"
  end

  @tag login_as: "unittest@unittest.com"
  test "Valid login", %{conn: conn, user: user} do
    session = %{"session" => %{"email" => user.email, "password" => user.password}}
    conn = post conn, session_path(conn, :create, session)
    assert get_flash(conn, :info) == "Welcome back!"
    assert redirected_to(conn, 302) == ticket_path(conn, :index)
  end  

  @tag login_as: "unittest@unittest.com"
  test "Valid login - invalid password", %{conn: conn, user: user} do
    session = %{"session" => %{"email" => user.email, "password" => "invalid"}}
    conn = post conn, session_path(conn, :create, session)
    assert get_flash(conn, :error) == "Invalid email or password"
    assert html_response(conn, 200) =~ "Welcome"
  end
  
  @tag login_as: "unittest@unittest.com"
  test "Valid login - invalid email", %{conn: conn} do
    session = %{"session" => %{"email" => "nope", "password" => "invalid"}}
    conn = post conn, session_path(conn, :create, session)
    assert get_flash(conn, :error) == "Invalid email or password"
    assert html_response(conn, 200) =~ "Welcome"
  end

  @tag login_as: "unittest@unittest.com"
  test "Logout - destroy session", %{conn: conn, user: user} do
    conn = delete conn, session_path(conn, :delete, user)
    assert get_flash(conn, :info) == "You have been logged out"
    assert redirected_to(conn, 302) == page_path(conn, :index)    
  end
end