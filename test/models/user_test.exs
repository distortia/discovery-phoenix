defmodule Discovery.UserTest do
  use Discovery.ModelCase
  use Discovery.ConnCase
  alias Discovery.User
  import Comeonin.Bcrypt, only: [checkpw: 2]

  @valid_attrs %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "Val1dP@ass", role: "User", auth_id: "123"}
  @invalid_attrs %{first_name: "invalid", auth_id: "123"}
  @updated_attrs_no_pass %{first_name: "New", last_name: "Name", password: "", email: "testuser@test.com", role: "User", auth_id: "123"}
  @updated_attrs_with_pass %{first_name: "New", last_name: "Name", password: "P@ssW3rd", email: "testuser@test.com", role: "User", auth_id: "123"}
  @new_role %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "Val1dP@ass", role: "Admin", auth_id: "123"}
  @valid_email %{email: "test@test.com"}
  @valid_email_caps %{email: "TEST@TEST.com"}
  @invalid_email %{email: "testuser"}
  @invalid_email_unique %{email: "testuser@test.com"}

  @valid_password %{password: "Val1dP@ass"}
  @invalid_password_length %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "1", role: "User", auth_id: "123"}
  @invalid_password_no_numbers %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "!nvalidPass", role: "User", auth_id: "123"}
  @invalid_password_no_lowercase %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "!NVALIDPASS", role: "User", auth_id: "123"}
  @invalid_password_no_uppercase %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "!nvalidpass", role: "User", auth_id: "123"}
  @invalid_password_no_special_character %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "1nvalidPass", role: "User", auth_id: "123"}
 
  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: email)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "Valid password changeset" do
    changeset = User.password_changeset(%User{}, @valid_password)
    assert changeset.valid?
  end

  test "invalid password changesets" do
    Enum.each([
      @invalid_attrs,
      @invalid_password_length,
      @invalid_password_no_uppercase,
      @invalid_password_no_lowercase,
      @invalid_password_no_numbers,
      @invalid_password_no_special_character,
      ], fn(requirements) ->
        changeset = User.password_changeset(%User{}, requirements) 
        refute changeset.valid?
      end)
  end

  test "Valid Email Changeset" do
    changeset = User.email_changeset(%User{}, @valid_email)
    assert changeset.valid?
  end

  test "Invalid email changesets" do
    changeset = User.email_changeset(%User{}, @invalid_email)
    refute changeset.valid?
  end

  test "Email is taken" do
    user = 
    User.registration_changeset(%User{}, @valid_attrs)
    |> Repo.insert!

    changeset = User.email_changeset(%User{}, %{email: "testuser@test.com"})
    {:error, changeset} = Repo.insert(changeset)
    assert changeset.errors == [email: "has already been taken"]
  end

  test "Emails are normalized" do
    email = "TEST@TEST.COM"
    changeset = User.email_changeset(%User{}, %{email: email})
    assert changeset.changes.email == String.downcase(email)
  end

  @tag login_as: "testuser@test.com"
  test "Update changeset for user profile - No password", %{conn: conn, user: user} do
      changeset = User.update_changeset(%User{}, @updated_attrs_no_pass)
      refute Map.has_key?(changeset.changes, :password)
  end

  @tag login_as: "testuser@test.com"
  test "Password update changeset with key: value format", %{conn: conn, user: user} do
    changeset = User.update_changeset(%User{}, @updated_attrs_with_pass)
    assert Map.has_key?(changeset.changes, :password)
  end  

  @tag login_as: "testuser@test.com"
  test "Password update changeset with key => value format", %{conn: conn, user: user} do
    changeset = User.update_changeset(%User{}, %{"first_name" => "New", "last_name" => "Name", "password" => "P@ssW3rd", "email" => "testuser@test.com", "role" => "User"})
    assert Map.has_key?(changeset.changes, :password)
  end

  @tag login_as: "testuser@test.com"
  test "Role gets updated into the changeset", %{conn: conn, user: user} do
    changeset = User.update_owner_changeset(%User{}, @new_role)
    assert changeset.valid?
    assert changeset.changes.role == "Admin"
  end

  @tag login_as: "testuser@test.com"
  test "Update Owner no change", %{conn: conn, user: user} do
    changeset = 
    Repo.get_by!(User, email: "testuser@test.com")
    |> User.update_owner_changeset(@valid_attrs)
    assert changeset.changes == %{}
  end

  test "Password Hash with password" do
    user = 
    User.registration_changeset(%User{}, @valid_attrs)
    |> Repo.insert!

    assert checkpw("Val1dP@ass", user.password_hash)
  end

  test "Update changeset for the true statement" do
    assert User.update_changeset(%User{}, %{}) == :ok
  end

  test "Update changeset - params[\"password\"]" do
    changeset = 
    User.update_changeset(%User{}, %{"first_name" => "Test", "last_name" => "User", "email" => "testuser@test.com", "password" => "", "role" => "User", "auth_id" => "123"})

  end
end
