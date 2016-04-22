defmodule Discovery.UserControllerTest do
  use Discovery.ConnCase

  alias Discovery.User

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: "unittest@unittest.com", first_name: "unit", last_name: "test", password: "123123")
      conn = assign(conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end
  
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

  test "GET /Users/new", %{conn: conn} do
      conn = get conn, "/users/new"
      assert html_response(conn, 200) =~ "Get Registered!"
  end
end
