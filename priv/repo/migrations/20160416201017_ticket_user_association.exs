# USER HAS MANY TICKETS ASSOCIATION
defmodule Discovery.Repo.Migrations.TicketUserAssociation do
  use Ecto.Migration

    def change do
    	alter table(:tickets) do
    		add :user_id, references(:users, on_delete: :nothing)
    	end
      create index(:tickets, [:user_id])
  end
end