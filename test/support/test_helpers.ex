defmodule Discovery.TestHelpers do
  alias Discovery.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      first_name: "Unit",
      last_name: "Test",
      email: "#{Base.encode16(:crypto.rand_bytes(8))}@unittest.com",
      password: "123123",
    }, attrs)

    %Discovery.User{}
    |> Discovery.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_ticket(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:tickets, attrs)
    |> Repo.insert!()
  end

  def insert_company() do
  	
  end
end