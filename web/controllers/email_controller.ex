defmodule Discovery.EmailController do
	use Discovery.Web, :controller

	alias Discovery.Email
	alias Discovery.Mailer
	alias Discovery.Company

	def invite(conn, %{"company" => company, "users" => users}) do
		company = 
		Repo.get!(Company, company)
		|> IO.inspect()
		# users="me@darrellpappa.com"
		for user <- users do
			Email.invite_email(company, user)
			|> Mailer.deliver_later()
		end
		conn
		|> put_flash(:info, "Invitiation sent!")
		|> redirect(to: company_path(conn, :show, company.id))
	end
end

# Define your emails
defmodule Discovery.Email do
  import Bamboo.Email

  def invite_email(company, user) do
    new_email
    |> to(user)
    |> from("support@alphaity.io")
    |> subject("Discovery - Invitation")
    |> html_body(
    	"You have been invited to join the company #{String.upcase(company.name)} in Discovery.
     	Click this link to join: ")
  end
end
