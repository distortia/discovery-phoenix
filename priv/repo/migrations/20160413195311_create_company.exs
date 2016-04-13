defmodule Discovery.Repo.Migrations.CreateCompany do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :name, :string
      # add :owner, references(:users, on_delete: :nothing)
      # add :memebers, references(:users, on_delete: :nothing)

      timestamps
    end
    # create index(:companies, [:owner])
    # create index(:companies, [:memebers])
    create unique_index(:companies, [:name])

  end
end
