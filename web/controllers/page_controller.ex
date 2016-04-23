defmodule Discovery.PageController do
  use Discovery.Web, :controller
  alias Discovery.Email
  alias Discovery.Mailer

  def index(conn, _params) do
    render conn, "index.html"
  end
  def email(conn, _params, company) do
  	Email.welcome_email |> Mailer.deliver_later
  	conn
  	|> put_flash(:info, "Invitiation sent!")
  	|> IO.inspect()
  	|> render "show.html", company: company
  end
end