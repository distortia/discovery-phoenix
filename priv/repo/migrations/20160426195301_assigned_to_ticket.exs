defmodule Discovery.Repo.Migrations.AssignedToTicket do
  use Ecto.Migration

  def change do
  	alter table(:tickets)  do
	  	add :assigned_to, :string
  	end
  end
end
