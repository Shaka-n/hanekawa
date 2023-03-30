defmodule Hanekawa.Repo do
  use Ecto.Repo,
    otp_app: :hanekawa,
    adapter: Ecto.Adapters.Postgres
end
