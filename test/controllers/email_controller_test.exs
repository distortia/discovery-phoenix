defmodule Discovery.EmailControllerTest do
  use Discovery.ConnCase

  alias Discovery.Company
  alias Discovery.User
  alias Discovery.EmailController

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: "nickstalter+unittest@gmail.com")
      company = insert_company()
      conn = 
      assign(conn(), :current_user, user)
      |> assign(:company, company)
      {:ok, conn: conn, user: user, company: company}
    else
      :ok
    end
  end

  @tag login_as: "unittest@unittest.com"  
  test "Create soft user - happy path", %{conn: conn, user: user, company: company} do
  	token = "123"
  	email = "nickstalter+unittest1@gmail.com"
  	assert {:ok, "created"} == EmailController.create_soft_user(email, token)
  end

  @tag login_as: "unittest@unittest.com"  
  test "Create soft user - user already invited - no registration - updates token", %{conn: conn, user: user, company: company} do
  	token = "123"
  	email = "nickstalter+unittest1@gmail.com"
  	EmailController.create_soft_user(email, token)
  	assert {:ok, "updated"} == EmailController.create_soft_user(email, token)
  end

  @tag login_as: "unittest@unittest.com"  
  test "Create soft user - user already registered", %{conn: conn, user: user, company: company} do
  	token = "123"
  	email = "nickstalter+unittest@gmail.com"
  	assert {:error, "exists"} == EmailController.create_soft_user(email, token)
  end
  
  @tag login_as: "unittest@unittest.com"
  test "Invite one user - happy path", %{conn: conn, user: user, company: company} do
  	company = insert_company(name: "testComp")
  	users = %{"email" => "nickstalter+unittest1@gmail.com"}
  	conn = post conn, email_path(conn, :invite, company.id), company: company.id, users: users
	assert get_flash(conn, :info) == "Invitation sent!"
	assert redirected_to(conn) == company_path(conn, :show, company.id)
  end  

  @tag login_as: "unittest@unittest.com"
  test "Invite one user - user already registered", %{conn: conn, user: user, company: company} do
  	company = insert_company(name: "testComp", unique_id: "123")
  	users = %{"email" => "nickstalter+unittest@gmail.com"}
  	conn = post conn, email_path(conn, :invite, company.id), company: company.id, users: users
  	assert get_flash(conn, :error) == "The user you invited has already registered."
	assert redirected_to(conn) == company_path(conn, :show, company.id)
  end

	@tag login_as: "unittest@unittest.com"
	test "Invite many users - happy path", %{conn: conn, user: user, company: company} do
		company = insert_company(name: "testComp", unique_id: "123")
		users = %{"email" => "unittest+unittest@gmail.com, blah@blah.net"}
		conn = post conn, email_path(conn, :invite, company.id), company: company.id, users: users
		assert get_flash(conn, :info) == "Invitation sent!"
		assert redirected_to(conn) == company_path(conn, :show, company.id)
	end	

	@tag login_as: "unittest@unittest.com"
	test "Invite many users - one user is already registered", %{conn: conn, user: user, company: company} do
		company = insert_company(name: "testComp", unique_id: "123")
		users = %{"email" => "nickstalter+unittest@gmail.com, blah@blah.net"}
		conn = post conn, email_path(conn, :invite, company.id), company: company.id, users: users
		assert get_flash(conn, :warn) == "One of the users you invited has already registered. Any other invites were sent."
		assert redirected_to(conn) == company_path(conn, :show, company.id)
	end
end