defmodule Discovery.UserControllerTest do
  use Discovery.ConnCase

  alias Discovery.User

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: email)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  @valid_attrs %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "Val1dP@ass", role: "User", auth_id: "123"}
  @invalid_attrs %{first_name: "invalid", auth_id: "123"}
  
  test "Redirect from /users to index with error due to authentication", %{conn: conn} do
    Enum.each([
      get(conn, user_path(conn, :index)),
      get(conn, user_path(conn, :show, "1")),
      get(conn, user_path(conn, :edit, "1")),
      put(conn, user_path(conn, :update, "1", %{})),
      delete(conn, user_path(conn, :delete, "1")),
      ], fn conn -> 
           assert redirected_to(conn, 302) =~ "/sessions/new"
           assert get_flash(conn, :error) == "Error, You must be logged in to access this page"
      end)
  end

  @tag login_as: "unittest@unittest.com"
  test "Cannot create a user while logged in", %{conn: conn, user: user} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    # assert 
  end
  
  test "Redirect when attempted to make a user without an invite", %{conn: conn} do
    Enum.each([
        get(conn, "/users/new"),
        get(conn, "/users/new/1"),
      ], fn conn -> 
          assert redirected_to(conn, 302) =~ "/"
          assert get_flash(conn, :error) == "You must be invited before you can create an account. Please contact support or your organizational leader for help."
    end)
  end 
  
  @tag login_as: "unittest@unittest.com"
  test "Get /Users", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing users/
  end
end
