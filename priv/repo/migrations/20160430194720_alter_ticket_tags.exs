defmodule Discovery.Repo.Migrations.AlterTicketTags do
  use Ecto.Migration

  def change do
  	alter table(:tickets) do
  		modify :tags, {:array, :string}, default: []
  	end
  end
end
