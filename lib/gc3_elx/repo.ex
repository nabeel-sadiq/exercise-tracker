defmodule Gc3Elx.Repo do
  use Ecto.Repo,
    otp_app: :gc3_elx,
    adapter: Ecto.Adapters.SQLite3
end
