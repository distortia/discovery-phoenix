# COMPANY HAS MANY USERS ASSOCIATION
defmodule Discovery.Repo.Migrations.UserCompanyAssociation do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :company_id, references(:companies, on_delete: :nothing)
    end
    create index(:users, [:company_id])
  end
end
