defmodule Discovery.GitHub do
	
	def create_oauth(code) do
		response = HTTPoison.post "https://github.com/login/oauth/access_token?client_id=2b2ea096468468afacb2&client_secret=aebc18d1b6fc4df73d0341fddcd2f872f8a72cae&code=#{code}", "{\"data\":1}", %{}, [{"User-Agent", "Elixir"}]
		case response do
			{:ok, response} -> response
			_ -> :error
		end
	end
	
end 