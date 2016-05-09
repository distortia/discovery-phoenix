defmodule Discovery.TestHelpers do
  alias Discovery.Repo
  alias Discovery.User

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      first_name: "Unit",
      last_name: "Test",
      email: "#{Base.encode16(:crypto.rand_bytes(8))}@unittest.com",
      password: "Val1dP@ass",
      role: "User",
      auth_id: "123"
    }, attrs)

    %Discovery.User{}
    |> Discovery.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_soft_user(attrs) do
    Repo.insert!(%User{email: attrs[:email], auth_id: attrs[:token]})
  end

  def insert_ticket(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:tickets, attrs)
    |> Repo.insert!()
  end

  def insert_company(attrs \\ %{}) do
  	changes = Dict.merge(%{
      name: "testComp",
      unique_id: "1"
      }, attrs)

    %Discovery.Company{}
    |> Discovery.Company.changeset(changes)
    |> Repo.insert!()
  end
end