defmodule Discovery.Repo.Migrations.CompanyUniqueId do
  use Ecto.Migration

  def change do
  	alter table(:companies) do
  		add :unique_id, :string
  	end
  	create unique_index(:companies, [:unique_id])
  end
end
