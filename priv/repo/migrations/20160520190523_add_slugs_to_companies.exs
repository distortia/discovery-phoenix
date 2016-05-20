defmodule Discovery.Repo.Migrations.AddSlugsToCompanies do
  use Ecto.Migration

  def change do
  	alter table(:companies) do
  		add :slug, :string
  	end
  end
end
