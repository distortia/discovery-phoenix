defmodule Discovery.UserControllerTest do
  use Discovery.ConnCase

  alias Discovery.User

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(email: email)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  @valid_attrs %{first_name: "Test", last_name: "User", email: "testuser@test.com", password: "Val1dP@ass", role: "User", auth_id: "123"}
  @invalid_attrs %{first_name: "invalid", auth_id: "123"}
  
  test "Redirect from /users to index with error due to authentication", %{conn: conn} do
    Enum.each([
      get(conn, user_path(conn, :index)),
      get(conn, user_path(conn, :show, "1")),
      get(conn, user_path(conn, :edit, "1")),
      put(conn, user_path(conn, :update, "1", %{})),
      delete(conn, user_path(conn, :delete, "1")),
      ], fn conn -> 
           assert redirected_to(conn, 302) =~ "/sessions/new"
           assert get_flash(conn, :error) == "Error, You must be logged in to access this page"
      end)
  end

  @tag login_as: "unittest@unittest.com"
  test "Cannot create a user while logged in", %{conn: conn, user: user} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    # assert 
  end
  
  test "Redirect when attempted to make a user without an invite", %{conn: conn} do
    Enum.each([
        get(conn, "/users/new"),
        get(conn, "/users/new/1"),
      ], fn conn -> 
          assert redirected_to(conn, 302) =~ "/"
          assert get_flash(conn, :error) == "You must be invited before you can create an account. Please contact support or your organizational leader for help."
    end)
  end 
  
  @tag login_as: "unittest@unittest.com"
  test "Get /Users", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing users/
  end

  test "Render users/new with company id + token", %{conn: conn} do
    conn = get conn, user_path(conn, :new, "123", "123")
    assert html_response(conn, 200) =~ "Get Registered!"
  end

  test "Render reset password", %{conn: conn} do
    conn = get conn, user_path(conn, :reset)
    assert html_response(conn, 200) =~ "Reset Password"
  end

  test "Render new password", %{conn: conn} do
    conn = get conn, user_path(conn, :new_password, "123")
    assert html_response(conn, 200) =~ "Update Password"
  end

  test "Create user", %{conn: conn} do
    user = insert_soft_user(email: "softuser@me.com", auth_id: "123")
    company = insert_company()
    user_params = 
      %{email: user.email, first_name: "Test", last_name: "User", 
        password: "Val1dP@ass", auth_id: "123", unique_company_id: "#{company.unique_id}", role: "User"}
    conn = post conn, user_path(conn, :create, %{"user" => user_params})
    assert get_flash(conn, :info) == "Welcome #{user_params.first_name} #{user_params.last_name}!"
    assert redirected_to(conn, 302) == company_path(conn, :join_company, company: company.id)
  end  

  test "Create user - invalid changeset", %{conn: conn} do
    user = insert_soft_user(email: "softuser@me.com", auth_id: "123")
    company = insert_company()
    user_params = 
      %{email: user.email, first_name: "Test", last_name: "User", 
        password: "Val1dP@ass", auth_id: "123", unique_company_id: "#{company.unique_id}"}
    conn = post conn, user_path(conn, :create, %{"user" => user_params})
    assert html_response(conn, 200) =~ "Oops, something went wrong! Please check the errors below."
  end

  @tag login_as: "unittest@unittest.com"
  test "Show user", %{conn: conn, user: user} do
    {:ok, user} = join_company(user, insert_company())
    conn = get conn, user_path(conn, :show, user.id)
    assert html_response(conn, 200) =~ user.first_name
  end

  @tag login_as: "unittest@unittest.com"
  test "Edit user", %{conn: conn, user: user} do
    {:ok, user} = join_company(user, insert_company())
     conn = get conn, user_path(conn, :edit, user.id)
     assert html_response(conn, 200) =~ "Edit user"
  end

  @tag login_as: "unittest@unittest.com"
  test "Update user", %{conn: conn, user: user} do
    {:ok, user} = join_company(user, insert_company())
    user_params = %{"user" => %{first_name: "New", last_name: "Name", password: ""}}
    conn = put conn, user_path(conn, :update, user.id, user_params)
    assert get_flash(conn, :info) == "User updated successfully."
    assert redirected_to(conn, 302) == user_path(conn, :show, user.id)
  end

  @tag login_as: "unittest@unittest.com"
  test "Update user - update role", %{conn: conn, user: user} do
      {:ok, user} = join_company(user, insert_company())
      user_params = %{"user" => %{first_name: "New", last_name: "Name", role: "Admin", password: ""}}
      conn = put conn, user_path(conn, :update, user.id, user_params)
      assert get_flash(conn, :info) == "User updated successfully."
      assert redirected_to(conn, 302) == user_path(conn, :show, user.id)
  end

  @tag login_as: "unittest@unittest.com"
  test "Update user - update role - Owner", %{conn: conn, user: user} do
      {:ok, user} = join_company(user, insert_company())
      user_params = %{"user" => %{first_name: "a", last_name: "a", role: "Owner", password: ""}}
      conn = put conn, user_path(conn, :update, user.id, user_params)
      assert get_flash(conn, :info) == "User updated successfully."
      assert redirected_to(conn, 302) == user_path(conn, :show, user.id)
  end  

  @tag login_as: "unittest@unittest.com"
  test "Update user - invalid changeset - blank name", %{conn: conn, user: user} do
      {:ok, user} = join_company(user, insert_company())
      user_params = %{"user" => %{first_name: "a", last_name: "", password: ""}}
      conn = put conn, user_path(conn, :update, user.id, user_params)
      assert html_response(conn, 200) =~ "Oops, something went wrong! Please check the errors below."
      assert html_response(conn, 200) =~ "should be at least 1 character(s)"
  end

  # @tag login_as: "unittest@unittest.com"
  # test "Change owner", %{conn: conn, user: user} do
  #   owner = insert_user(email: "test123@test.com", first_name: "second", last_name: "user", role: "Owner")
  #   company = insert_company()
  #   {:ok, owner} = join_company(owner, company)
  #   {:ok, user} = join_company(user, company)
  #   user_params = %{"user" => %{first_name: "first", last_name: "user", role: "Owner", password: ""}}
  #   conn = put conn, user_path(conn, :update, user.id, user_params)
  #   assert get_flash(conn, :info) == "User updated successfully."
  #   updated_company = Repo.get!(Discovery.Company, company.id) |> Repo.preload(:users)
  #   IO.inspect updated_company
  #   # assert updated_company.owner = 
  # end

  @tag login_as: "unittest@unittest.com"
  test "Delete user - no tickets", %{conn: conn, user: user} do
    conn = delete conn, user_path(conn, :delete, user.id)
    assert get_flash(conn, :info) == "User deleted successfully."
    assert redirected_to(conn, 302) == user_path(conn, :index)
    assert Repo.get(User, user.id) == nil
  end 

  @tag login_as: "unittest@unittest.com"
  test "Delete user - with tickets", %{conn: conn, user: user} do
    ticket = insert_ticket(user, title: "unit test ticket", body: "unit test body", assigned_to: "#{user.id}")
    conn = delete conn, user_path(conn, :delete, user.id)
    assert get_flash(conn, :error) == "Please re-assign all tickets from this user before deleting"
    assert redirected_to(conn, 302) == user_path(conn, :index)
    assert Repo.get(User, user.id) !== nil
    assert conn.halted
  end
   
  test "Update Password", %{conn: conn} do
    user = insert_user(auth_id: "123")
    update_params = %{"update_form" => %{password: "Val1dP@ass", auth_id: "123"}}
    conn = post conn, user_path(conn, :update_password, update_params)
    assert get_flash(conn, :info) == "Password updated successfully."
    assert redirected_to(conn, 302) == ticket_path(conn, :index)
    assert Repo.get_by(User, auth_id: "123") == nil
  end

  test "Update password - invalid auth_id", %{conn: conn} do
    update_params = %{"update_form" => %{password: "Val1dP@ass", auth_id: "invalid"}}
    conn = post conn, user_path(conn, :update_password, update_params)
    assert get_flash(conn, :error) == "Unauthorized attempt to change a password. Please try going through the reset password flow again."
    assert redirected_to(conn, 302) == user_path(conn, :reset)
    assert conn.halted
  end

  test "Update Password - invalid password", %{conn: conn} do
    user = insert_user(auth_id: "123")
    update_params = %{"update_form" => %{password: "invalid1", auth_id: user.auth_id}}
    conn = post conn, user_path(conn, :update_password, update_params)
    assert html_response(conn, 200) =~ "has invalid format"
  end
end