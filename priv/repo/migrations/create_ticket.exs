# Basic Ticket column creation
# BEFORE ASSOCIATIONS
defmodule Discovery.Repo.Migrations.CreateTicket do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :title, :string
      add :body, :text
      add :resolution, :text
      add :created_on, :string
      add :severity, {:array, :integer}
      add :updated_on, :string
      add :tags, {:array, :string}
      add :status, {:array, :string}

      timestamps
    end

  end
end
