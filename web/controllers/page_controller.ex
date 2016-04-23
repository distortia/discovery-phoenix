defmodule Discovery.PageController do
  use Discovery.Web, :controller
  alias Discovery.Email
  alias Discovery.Mailer
  alias Discovery.Company

  def index(conn, _params) do
    render conn, "index.html"
  end
end