defmodule Discovery.Repo.Migrations.ModifyCompanyTagsDefautlValues do
  use Ecto.Migration

  def change do
  	alter table(:companies) do
  		modify :company_tags, {:array, :string}, default: []
  	end
  end
end
