defmodule Discovery.TestHelpers do
  alias Discovery.Repo
  alias Discovery.User
  alias Discovery.Company
  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      first_name: "Unit",
      last_name: "Test",
      email: "#{Base.encode16(:crypto.rand_bytes(8))}@unittest.com",
      password: "Val1dP@ass",
      role: "User",
      auth_id: ""
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
      name: "UnitTestComp",
      unique_id: "#{Base.encode16(:crypto.rand_bytes(8))}",
      company_tags: [],
      }, attrs)

    %Discovery.Company{}
    |> Discovery.Company.changeset(changes)
    |> Repo.insert!()
  end

  def join_company(user, company) do
    user = Repo.preload(user, :company)

    company = 
    Repo.get!(Company, company.id)
    |> Ecto.build_assoc(:users, Map.from_struct user)

    Repo.update(company)
  end
end