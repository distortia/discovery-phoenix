defmodule Discovery.Repo.Migrations.AddCreatedByToTicket do
  use Ecto.Migration

  def change do
  	alter table(:tickets) do
  	add :created_by, :string
  	end
  end
end
