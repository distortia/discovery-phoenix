defmodule Discovery.SessionController do
	use Discovery.Web, :controller

	def new(conn, _) do
		render conn, "new.html"
	end

	def create(conn, %{"session"=> %{"email" => email, "password" => pass}}) do
		case Discovery.Auth.login_by_email_and_pass(conn, email, pass, repo: Repo) do
			{:ok, conn} ->
				conn
				|> put_flash(:info, "Welcome Back!")
				|> redirect(to: ticket_path(conn, :index))
			{:error, _reason, conn} ->
				conn
				|> put_flash(:error, "Invalid email or password")
				|> render("new.html")
		end
	end

	def delete(conn, _) do
		conn
		|> Discovery.Auth.logout()
		|> redirect(to: page_path(conn, :index))
	end
end