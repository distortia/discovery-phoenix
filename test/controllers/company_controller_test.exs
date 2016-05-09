defmodule Discovery.CompanyControllerTest do
  use Discovery.ConnCase

  alias Discovery.Company

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: "unittest@unittest.com", first_name: "unit", last_name: "test", password: "123123")
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
end