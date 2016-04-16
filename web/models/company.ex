defmodule Discovery.Company do
  use Discovery.Web, :model

  alias Discovery.User
  alias Discovery.Ticket

  schema "companies" do
    field :name, :string
    
    has_many :users, User
    # Sets up the user ticket company relationship
    has_many :user_tickets, through: [:users, :tickets]

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

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
end
