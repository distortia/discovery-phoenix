defmodule Discovery.TicketTest do
  use Discovery.ModelCase

  alias Discovery.Ticket

  @valid_attrs %{body: "some content", created_on: "2010-04-17 14:00:00", resolution: "some content", severity: "Normal", status: "Open", tags: [], title: "some content", updated_on: "2010-04-17 14:00:00", assigned_to: "1"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Ticket.changeset(%Ticket{}, @valid_attrs)
    IO.inspect changeset.errors
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Ticket.changeset(%Ticket{}, @invalid_attrs)
    refute changeset.valid?
  end
end
