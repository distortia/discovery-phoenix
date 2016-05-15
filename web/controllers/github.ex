defmodule Discovery.GitHub do
	
	def create_oauth(code) do
		response = HTTPoison.post "https://github.com/login/oauth/access_token?client_id=2b2ea096468468afacb2&client_secret=aebc18d1b6fc4df73d0341fddcd2f872f8a72cae&code=#{code}", "{\"data\":1}", %{}, [{"User-Agent", "Elixir"}]
		case response do
			{:ok, response} -> response
			_ -> :error
		end
	end
	
	def get_repos(code) do
		response = HTTPoison.get "https://api.github.com/user/repos?access_token=#{code}", [{"User-Agent", "Elixir"}]
		case response do 
			{:ok, response} -> response
			_ -> :error
		end
	end 

	def create_issue(code, owner, repo, name, body) do
		post_body = %{"title" => name, "body"=>body}
		response = HTTPoison.post "https://api.github.com/repos/#{owner}/#{repo}/issues?access_token=#{code}", Poison.encode!(post_body)
		case response do
			{:ok, response} -> response
			_ -> :error
		end
	end
end 