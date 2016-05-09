defmodule Discovery.EmailControllerTest do
  use Discovery.ConnCase

  alias Discovery.Company
  alias Discovery.User

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
  
  @tags login_as: "unittest@unittest.com"
  test "Invite user", %{conn: conn, user: user} do

    # Flash message saying Invitaion sent!
    # Redirected back to company page
  end

  test "Invite a user who already registered", %{conn: conn} do
    # flash message is User: nickstalter+4@gmail.com already registered
    # And you are on the company page
  end

end