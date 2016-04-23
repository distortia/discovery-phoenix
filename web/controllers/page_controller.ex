defmodule Discovery.PageController do
  use Discovery.Web, :controller
  alias Discovery.Email
  alias Discovery.Mailer

  def index(conn, _params) do
    render conn, "index.html"
  end
  def email(conn, _params) do
  	Email.welcome_email |> Mailer.deliver_later
  	conn
  	|> put_flash(:info, "Invitiation sent")
  	|> render "index.html"
  end
end