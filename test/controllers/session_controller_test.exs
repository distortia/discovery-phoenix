defmodule Discovery.SessionControllerTest do
  use Discovery.ConnCase

  alias Discovery.SessionController

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: "unittest@unittest.com", first_name: "unit", last_name: "test", password: "123123")
      conn = assign(conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "GET /session/new", %{conn: conn} do
      conn = get conn, "/sessions/new"
      assert html_response(conn, 200) =~ "Login"
  end
end