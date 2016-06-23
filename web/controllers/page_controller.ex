defmodule Discovery.PageController do
  use Discovery.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def chat_view(conn, _params) do
  	render conn, "chat.html"
  end
end