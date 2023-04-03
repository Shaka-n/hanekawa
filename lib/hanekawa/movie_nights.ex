defmodule Hanekawa.MovieNights do
  @moduledoc """
  This module contains the context for CRUD actions for movie nights.
  """
  import Ecto.Query

  alias Hanekawa.MovieNight
  alias Hanekawa.Repo

  require Logger

  def create_movie_night(attrs) do
    %MovieNight{}
    |> MovieNight.changeset(attrs)
    |> Repo.insert()
  end

  # This function should return the next scheduled movie night
  def get_next_movie_night() do
    today = Date.utc_today()
    MovieNight
    |> where([mn], mn.date >= ^today)
    |> Repo.one()
  end

  # This function should reschedule a movie night scheduled on the provided date with the given attrs.
  def reschedule_movie_night(date, attrs) do
    with {:ok, movie_night} <- get_movie_night_by_date(date) do
      update_movie_night(movie_night, attrs)
    else
      err ->
        err
    end
  end

  # This function should update a given movie night with the given attrs
  defp update_movie_night(movie_night, attrs) do
    movie_night
    |> MovieNight.changeset(attrs)
    |> Repo.update()
  end

  # Cancels a movie night on the given date.
  def cancel_movie_night(date) do
    with {:ok, movie_night} <- get_movie_night_by_date(date) do
      delete_movie_night(movie_night)
    else
      err ->
        err
    end
  end

  # Deletes a given movie night
  defp delete_movie_night(movie_night) do
    Repo.delete(movie_night)
  end

  # This function should take an ISO8601 date (i.e. 3-6-23) and return a movie night if there is one scheduled for that date.
  defp get_movie_night_by_date(date_string) do
    with {:ok, date} <- Date.from_iso8601(date_string) do
      Repo.get_by(MovieNight, date: date)
    else
      err ->
        err
      end
  end
end
