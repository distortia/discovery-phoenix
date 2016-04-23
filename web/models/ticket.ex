defmodule Discovery.Ticket do
  use Discovery.Web, :model

  alias Discovery.Company
  alias Discovery.User
  
  schema "tickets" do
    field :title, :string
    field :body, :string
    field :resolution, :string
    field :created_on, :string
    field :severity, {:array, :integer}
    field :updated_on, :string
    field :tags, {:array, :string}
    field :status, :string, default: "Open"
    field :created_by, :string

    # Set relationship to user
    belongs_to :user, User

    timestamps
  end

  @required_fields ~w(title body)
  @optional_fields ~w(resolution tags status)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
