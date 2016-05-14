defmodule Discovery.Repo.Migrations.AddOauthTokensToCompany do
  use Ecto.Migration

  def change do
  	alter table(:companies) do
      add :oauth_tokens, :map
    end
  end
end
