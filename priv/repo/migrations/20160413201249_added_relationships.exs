defmodule Discovery.Repo.Migrations.AddedRelationships do
  use Ecto.Migration

  def change do
  	alter table(:users) do
    add :password_hash, :string
		add :companies, references(:companies, on_delete: :nothing)
  	end

  	alter table(:tickets) do
		add :assigned_to, references(:users, on_delete: :nothing)
		add :company_id, references(:companies, on_delete: :nothing)
		add :created_by, references(:users, on_delete: :nothing)
  	end

  	alter table(:companies) do
  		add :owner, references(:users, on_delete: :nothing)
  		add :memebers, references(:users, on_delete: :nothing)
  	end

	create index(:users, [:companies])

   	create index(:tickets, [:assigned_to])
    create index(:tickets, [:company_id])
    create index(:tickets, [:created_by])

    create index(:companies, [:owner])
    create index(:companies, [:memebers])
  end
end
