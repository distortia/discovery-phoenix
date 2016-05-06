defmodule Discovery.UserTest do
  use Discovery.ModelCase
  use Discovery.ConnCase
  alias Discovery.User

  @valid_attrs %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "Val1dP@ass", role: "User", auth_id: "123"}
  @invalid_attrs %{first_name: "invalid", auth_id: "123"}

  @valid_email %{email: "test@test.com"}
  @invalid_email %{email: "testuser"}
  @invalid_email_unique %{email: "testuser@test.com"}

  @valid_password %{password: "P@ssw0rd!"}
  @invalid_password_length %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "1", role: "User", auth_id: "123"}
  @invalid_password_no_numbers %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "!nvalidPass", role: "User", auth_id: "123"}
  @invalid_password_no_lowercase %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "!NVALIDPASS", role: "User", auth_id: "123"}
  @invalid_password_no_uppercase %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "!nvalidpass", role: "User", auth_id: "123"}
  @invalid_password_no_special_character %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "1nvalidPass", role: "User", auth_id: "123"}

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
      insert_user(email: "testuser@test.com")
      |> IO.inspect()
      Enum.each([
        @invalid_email,
        @invalid_email_unique
      ], fn(requirements) ->
        changeset = User.email_changeset(%User{}, requirements) 
        refute changeset.valid?
      end)
  end
end
