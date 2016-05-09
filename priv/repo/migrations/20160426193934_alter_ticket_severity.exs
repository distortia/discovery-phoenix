defmodule Discovery.Repo.Migrations.AlterTicketSeverity do
  use Ecto.Migration

  def change do
  	alter table(:tickets) do
  		modify :severity, :string
  	end
  end
end
