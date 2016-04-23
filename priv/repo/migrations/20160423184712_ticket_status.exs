defmodule Discovery.Repo.Migrations.TicketStatus do
  use Ecto.Migration

  def change do
  	alter table(:tickets) do
		modify :status, :string, default: "Open"
  	end
  end
end
