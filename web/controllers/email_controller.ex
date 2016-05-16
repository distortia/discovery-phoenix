defmodule Discovery.EmailController do
	use Discovery.Web, :controller

	alias Discovery.Email
	alias Discovery.Mailer
	alias Discovery.Company
	alias Discovery.User

	def invite(conn, %{"company" => company, "users" => users}) do
		company = Repo.get!(Company, company)
		users_list = 
		users["email"] 
		|> String.split(",")
		# Creates soft users for all email addresses passed in
		# Returns a list of atoms
		invite_list = 
		Enum.map(users_list, fn(email) -> 
			token = random_string(10)
			link = "http://localhost:4000/users/new/#{company.unique_id}/#{token}"
			case create_soft_user(email, token) do
				{:error, "exists"} ->
					:error
				{:ok, _} ->
					Email.invite_email(company, email, link)
					|> Mailer.deliver_now()
					:ok
			end
		end)
		# Check if we got any errors back from the creation of soft users
		if Enum.member?(invite_list, :error) do
			case Enum.count(invite_list) do
				# If we only invited 1 user and they have already registered 
				1 ->
					conn
					|> put_flash(:error, "The user you invited has already registered.")
					|> redirect(to: company_path(conn, :show, company.id))
				# We got an error when trying to register n users
				_ ->
					conn
					|> put_flash(:warn, "One of the users you invited has already registered. Any other invites were sent.")
					|> redirect(to: company_path(conn, :show, company.id))
			end
		# No errors found
		else
			conn
			|> put_flash(:info, "Invitation sent!")
			|> redirect(to: company_path(conn, :show, company.id))
		end
	end
	# Will always return a successful response to deter email phishing
	def reset(conn, %{"reset_form" => reset_params}) do
		# Get email from the form
		email = reset_params["email"]
		# Generate random number of length 10
		random_auth_id = random_string(10)
		# Get our user
		case Repo.get_by(User, email: email) do
			nil -> 
				# do nothing
				conn 
				|> put_flash(:info, "Reset password instructions have been sent to #{email}")
				|> redirect(to: user_path(conn, :reset))
			_ -> 
			user = 
			Repo.get_by!(User, email: email)
			# Update the changeset to add the auth id
			|> Ecto.Changeset.change(auth_id: random_auth_id)

			case Repo.update(user) do
				{:ok, _user} ->
					# Send the email
					link = "http://localhost:4000/users/reset/#{random_auth_id}"
					Email.reset_password_email(email, link)
					|> Mailer.deliver_later

					conn
					|> put_flash(:info, "Reset password instructions have been sent to #{email}")
					|> redirect(to: user_path(conn, :reset)) 
			end
		end
	end

	# http://stackoverflow.com/questions/32001606/how-to-generate-a-random-url-safe-string-with-elixir
	defp random_string(length) do
  		:crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
	end

	def create_soft_user(email, token) do
		# Create a user in the DB with the email its being sent to and associate it to the auth id
		user = Repo.get_by(User, email: email)
		case user do
			nil -> # User wasnt found go ahead and make a user
				Repo.insert(%User{email: email, auth_id: token})
				{:ok, "created"}
			_ -> # Otherwise we have a registered or invited user 
			case (user.auth_id != "") do # Check if name is blank, that is the default setup for creating a soft user
				 true -> # User hasnt finished registration - update their token
					# Repo.update(user, %User{auth_id: token})
					Repo.update(Ecto.Changeset.change user, auth_id: token)
					{:ok, "updated"}
				_ -> # User already registered
					{:error, "exists"}
			end
		end
	end
end

# Define your emails
defmodule Discovery.Email do
  import Bamboo.Email

  def invite_email(company, email, link) do
    new_email
    |> to(email)
    |> from("support@alphaity.io")
    |> subject("Discovery - Invitation")
    |> html_body(
    	"You have been invited to join the company #{String.upcase(company.name)} in Discovery.
     	Click this link to join: #{link}")
  end

	def reset_password_email(email, link) do
	  	new_email
	  	|> to(email)
	  	|> from("support@alphaity.io")
	  	|> subject("Reset Password")
	  	|> html_body("A request has been to reset your password, please follow this link to reset it: #{link}")
  	end
end
