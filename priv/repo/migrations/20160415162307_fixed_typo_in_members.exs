defmodule Discovery.Repo.Migrations.FixedTypoInMembers do
  use Ecto.Migration

  def change do
 	rename table(:companies), :memebers, to: :members
  end
end
