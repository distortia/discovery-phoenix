defmodule Discovery.User do
  use Discovery.Web, :model

  alias Discovery.Company
  alias Discovery.Ticket
  
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string, unique: true
    field :password, :string, virtual: true
    field :password_hash, :string
    field :role, :string
    field :auth_id, :string
    
    belongs_to :company, Company
    has_many :tickets, Ticket
    
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(first_name last_name email role), ~w(auth_id))
    |> unique_constraint(:email)
    |> validate_length(:email, min: 1)
    |> validate_format(:email, ~r/@/) # Checks for @ sign in email
    |> update_change(:email, &String.downcase/1) # Normalize all emails
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/[a-z]/)
    |> validate_format(:password, ~r/[A-Z]/)
    |> validate_format(:password, ~r/[0-9]/)
    |> validate_format(:password, ~r/[!@#$%^&+=]/)
    |> put_pass_hash()
  end

  def update_changeset(model, params) do
    case params["password"] do
      "" ->
        model
        |> changeset(params)
      _ ->
        model
        |> changeset(params)
        |> cast(params, ~w(password), [])
        |> validate_length(:password, min: 8)
        |> validate_format(:password, ~r/[a-z]/)
        |> validate_format(:password, ~r/[A-Z]/)
        |> validate_format(:password, ~r/[0-9]/)
        |> validate_format(:password, ~r/[!@#$%^&+=]/)
        |> put_pass_hash()
    end
  end

  def update_owner_changeset(model, params) do
     model
     |> cast(params, ~w(role), [])
  end
  
  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
