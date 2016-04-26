defmodule Discovery.EmailController do
	use Discovery.Web, :controller

	alias Discovery.Email
	alias Discovery.Mailer
	alias Discovery.Company
	alias Discovery.User

	def invite(conn, %{"company" => company}) do
		company = 
		Repo.get!(Company, company)
		|> IO.inspect()
		user="me@darrellpappa.com"
		Email.welcome_email(company, user)
		|> Mailer.deliver_later()

		conn
		|> put_flash(:info, "Invitiation sent!")
		|> redirect(to: company_path(conn, :show, company.id))
	end

	def reset(conn, %{"reset_form" => reset_params}) do
		# Get email from the form
		email = reset_params["email"]
		# Generate random number of length 10
		random_auth_id = random_string(10)
		# Get our user
		user = 
		Repo.get_by!(User, email: email)
		# Update the changeset to add the auth id
		|> Ecto.Changeset.change(auth_id: random_auth_id)

		case Repo.update(user) do
			{:ok, _user} ->
				# Send the email
				link = "http://localhost:4000/users/password/"
				Email.reset_password_email(email, link)
				|> Mailer.deliver_later

				conn
				|> put_flash(:info, "Reset password instructions have been sent to #{email}")
				|> redirect(to: user_path(conn, :reset)) 
		
			{:error, _error} ->
				conn
				|> put_flash(:error, "Something went wrong, please contact support and try again")
				|> redirect(to: user_path(conn, :reset))
		end
	end

	def random_string(length) do
  		:crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
	end
end

# Define your emails
defmodule Discovery.Email do
  import Bamboo.Email

  def welcome_email(company, user) do
    new_email
    |> to(user)
    |> from("support@alphaity.io")
    |> subject("Discovery - Invitation")
    |> html_body("You have been invited to join #{company.name}in Discovery. Click this link to join!")
  end

	def reset_password_email(email, link) do
	  	new_email
	  	|> to(email)
	  	|> from("support@alphaity.io")
	  	|> subject("Reset Password")
	  	|> html_body("A request has been to reset your password, please follow this link to reset it: #{link}")
  	end
end
