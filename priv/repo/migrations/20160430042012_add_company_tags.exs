defmodule Discovery.Repo.Migrations.AddCompanyTags do
  use Ecto.Migration

  def change do
  	alter table(:companies) do
      add :company_tags, {:array, :string}
    end
  end
end
