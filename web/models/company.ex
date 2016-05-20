defmodule Discovery.Company do
  use Discovery.Web, :model

  alias Discovery.User
  alias Discovery.Ticket

  schema "companies" do
    field :name, :string
    field :unique_id, :string
    field :company_tags, {:array, :string}, default: []
    field :oauth_tokens, :map
    field :slug, :string

    has_many :users, User
    # Sets up the user ticket company relationship
    has_many :user_tickets, through: [:users, :tickets]
    
    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(company_tags oauth_tokens unique_id slug)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
  end

  def slug_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> slugify_company_name()
  end

  @doc """
  Returns a lowercase, hyphenated string of the company name
  
  Examples:
  "test comapany" -> "test-company"
  "Test Company" -> "test-company"
  """
  defp slugify_company_name(changeset) do
    put_change(changeset, :slug, Slugger.slugify_downcase(changeset.params["name"]))
  end
end
