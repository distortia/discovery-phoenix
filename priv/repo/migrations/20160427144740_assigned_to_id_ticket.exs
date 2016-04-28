defmodule Discovery.Repo.Migrations.AssignedToIdTicket do
  use Ecto.Migration

  def change do
  	alter table(:tickets) do
  		add :assigned_to_name, :string
  	end
  end
end
