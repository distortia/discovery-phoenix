defmodule Discovery.AuthTest do
  use Discovery.ConnCase

  alias Discovery.Auth 

  test "Login with valid user", %{conn: conn} do
    assert false
    # assert get_flash(conn, :info) == "Welcome back!"
    # assert html_response(conn, 200) =~ "Listing tickets"
  end

  test "login with invalid email", %{conn: conn} do
    assert false
  end

  test "login with invalid password", %{conn: conn} do
    assert false
  end

  test "logout", %{conn: conn} do
    assert false
  end 
end