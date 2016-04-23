defmodule Discovery.PageController do
  use Discovery.Web, :controller
  alias Discovery.Email
  alias Discovery.Mailer
  alias Discovery.Company

  def index(conn, _params) do
    render conn, "index.html"
  end

  def email(conn, %{"company" => company}) do
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
end