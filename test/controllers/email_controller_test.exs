defmodule Discovery.EmailControllerTest do
	use Discovery.ConnCase
	use Bamboo.Test, shared: :true
	alias Discovery.Company
	alias Discovery.User
	alias Discovery.EmailController
	alias Discovery.Email

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

	test "Invite user email - single user", %{conn: conn} do
		company = insert_company(name: "testComp", unique_id: "123")
		email = "test@test.com"
		token = "123"
		link = "http://localhost:4000/users/new/#{company.unique_id}/#{token}"
		conn = Email.invite_email(company, email, link)
    	assert conn.to == email
    	assert conn.subject == "Discovery - Invitation"
    	assert conn.html_body =~ "You have been invited to join the company #{String.upcase(company.name)} in Discovery.
     	Click this link to join: #{link}"
	end

	test "Invite user email - multiple users", %{conn: conn} do
		company = insert_company(name: "testComp", unique_id: "123")
		emails = 
		"test@test.com, test2@test.com"
		|> String.split(",")

		token = "123"
		link = "http://localhost:4000/users/new/#{company.unique_id}/#{token}"
		Enum.each(emails, fn(email) -> 
			conn = Email.invite_email(company, email, link)
	    	assert conn.to == email
	    	assert conn.subject == "Discovery - Invitation"
	    	assert conn.html_body =~ "You have been invited to join the company #{String.upcase(company.name)} in Discovery.
     	Click this link to join: #{link}"
	     end)
	end

	test "Sending of invite user email", %{conn: conn} do
		company = insert_company(name: "testComp")
		unique_id = "123"
		email = "test@test.com"
		token = "123"
		link = "http://localhost:4000/users/new/#{unique_id}/#{token}"

		sent_email = 
		Email.invite_email(company, email, link)
		|> Discovery.Mailer.deliver_now

		# # Works with deliver_now and deliver_later
		assert_delivered_email(sent_email)
	end
end