defmodule Hanekawa.MovieNight do
  use Ecto.Schema
  import Ecto.Changeset

  # The creator_id corresponds to a Discord user id. This may be insecure, and may be removed pending further investigation.
  # An alternative would be to store the user's display name (not nickname), but this may amount to the same in the end.

  schema "movie_nights" do
    field :date, :date
    field :movie_title, :string, default: ""
    field :creator_id, :string

    timestamps()
  end

  def changeset(movie_night, attrs) do
    movie_night
    |> cast(attrs, [
      :date,
      :movie_title,
      :creator_id
    ])
    |> validate_required([
      :date
    ])
    |> unique_constraint(:date)
  end
end
