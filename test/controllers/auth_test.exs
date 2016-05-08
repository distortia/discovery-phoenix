defmodule Discovery.AuthTest do
  use Discovery.ConnCase

  alias Discovery.Auth 

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: email)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "Login with valid user", %{conn: conn} do
    user = insert_user(%{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "Val1dP@ass", role: "User", auth_id: "123"})
    assert login(conn, user)
  end

  test "Login by email and pass", %{conn: conn} do
    
  end

  test "Login by email and pass with invalid password" do
    
  end

  test "Login by email and pass with no user or password" do
    
  end

  test "login with invalid email", %{conn: conn} do
  
  end

  test "login with invalid password", %{conn: conn} do
  
  end

  @tags login_as: "unittest@unittest.com"
  test "logout", %{conn: conn, user: user} do
    assert logout(conn)
  end

  test "Authenticate user" do
    
  end 

  @tags login_as: "unittest@unittest.com"
  test "Authenticated not allowed - while logged in" do
    
  end  

  @tags login_as: "unittest@unittest.com"
  test "Authenticated not allowed - while not logged in" do
    
  end
end