# Basic Ticket column creation
# BEFORE ASSOCIATIONS
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

      timestamps
    end

  end
end
