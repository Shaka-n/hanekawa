defmodule Hanekawa.MovieNightFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via
  the Hanekawa.MovieNights context.
  """

  def movie_night_fixture(attrs \\ %{}) do
    # Creating a date and adding one day to indicate tomorrow.
    date = Date.add(Date.utc_today(), 1)

    {:ok, movie_night} =
      attrs
      |> Enum.into(%{
        date: date,
        creator_id: "1234567890",
        movie_title: "The Wizard SoSo"
      })
      |> Hanekawa.MovieNights.create_movie_night()

      movie_night
  end
end
