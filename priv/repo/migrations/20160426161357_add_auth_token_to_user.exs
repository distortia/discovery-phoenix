defmodule Discovery.Repo.Migrations.AddAuthTokenToUser do
  use Ecto.Migration

  def change do
  	alter table(:users) do
  		add :auth_id, :string
  	end
  end
end
