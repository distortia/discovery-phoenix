defmodule Discovery.Comment do
	use Ecto.Schema

	schema "comments" do
		field :body
		belongs_to :ticket, Discovery.Ticket
		field :posted_on
		timestamps
	end
end