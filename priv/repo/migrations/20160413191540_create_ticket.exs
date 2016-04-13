defmodule Discovery.Repo.Migrations.CreateTicket do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :title, :string
      add :body, :text
      add :resolution, :text
      add :created_on, :datetime
      add :severity, {:array, :integer}
      add :updated_on, :datetime
      add :tags, {:array, :string}
      add :status, {:array, :string}
      # add :assigned_to, references(:users, on_delete: :nothing)
      # add :company_id, references(:companies, on_delete: :nothing)
      # add :created_by, references(:users, on_delete: :nothing)
      timestamps
    end

    # create index(:tickets, [:assigned_to])
    # create index(:tickets, [:company_id])
    # create index(:tickets, [:created_by])

  end
end
