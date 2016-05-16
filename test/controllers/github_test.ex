defmodule Discovery.GithubTest do
  use Discovery.ConnCase

  alias Discovery.Github

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: "unittest@unittest.com", first_name: "unit", last_name: "test", password: "Val1dP@ass")
      company = insert_company(name: "testComp")
      user = join_company(user, company)
      conn = assign(conn(), :current_user, user)
      {:ok, conn: conn, user: user, company: company}
    else
      :ok
    end
  end

  @tag login_as: "unittest@unittest.com"
  test "Basic oauth", %{conn: conn, user: user, company: company} do
    
  end

end