defmodule Hanekawa.Repo.Migrations.AddChannelIdColumnToMovieNights do
  use Ecto.Migration

  def up do
    alter table("movie_nights") do
      add :channel_id, :string
    end
  end

  def down do
    alter table("movie_nights") do
      remove :channel_id
    end
  end
end
