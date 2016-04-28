defmodule Discovery.Repo.Migrations.UpdateTicketDates do
  use Ecto.Migration

  def change do
  	alter table(:tickets) do
  		modify :created_on, :string
  		modify :updated_on, :string
  	end
  end
end
