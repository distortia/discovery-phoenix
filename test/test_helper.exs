ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Discovery.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Discovery.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Discovery.Repo)

