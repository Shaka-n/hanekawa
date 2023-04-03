defmodule Hanekawa.Repo.Migrations.AddMovieNightTable do
  use Ecto.Migration

  def up do
    create table("movie_nights") do
      add :date, :date, null: :false
      add :movie_title, :string
      add :creator_id, :string

      timestamps()
    end
  end

  def down do
    drop table("movie_nights")
  end
end
