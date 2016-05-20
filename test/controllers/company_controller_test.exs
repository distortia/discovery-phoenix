defmodule Discovery.CompanyControllerTest do
  use Discovery.ConnCase

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: email, first_name: "unit", last_name: "test", password: "Val1dP@ass")
      company = insert_company(name: "testComp")
      conn = assign(conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "Redirect from /companies to index with error", %{conn: conn} do
    Enum.each([
      get(conn, company_path(conn, :index)),
      get(conn, company_path(conn, :show, "1")),
      get(conn, company_path(conn, :new)),
      get(conn, company_path(conn, :edit, "1")),
      post(conn, company_path(conn, :create, %{})),
      put(conn, company_path(conn, :update, "1", %{})),
      delete(conn, company_path(conn, :delete, "1")),
      ], fn conn -> 
        assert redirected_to(conn, 302) =~ "/sessions/new"
        assert get_flash(conn, :error) == "Error, You must be logged in to access this page"
      end)
  end

  @tag login_as: "unittest@unittest.com" 
  test "Render the company index page - not god user", %{conn: conn, user: user} do
    conn = get conn, company_path(conn, :index), user
    assert get_flash(conn, :error) == "Error, You do not have access do this"
    assert redirected_to(conn, 302) == page_path(conn, :index)
  end

end