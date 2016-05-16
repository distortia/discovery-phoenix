defmodule Discovery.PageControllerTest do
  use Discovery.ConnCase

	test "Index page - without authentication", %{conn: conn} do
		conn = get conn, "/"
		assert html_response(conn, 200) =~ "Welcome to Discovery!"
	end

end
