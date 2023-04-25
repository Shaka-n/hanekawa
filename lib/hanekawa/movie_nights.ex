defmodule Hanekawa.MovieNights do
  @moduledoc """
  This module contains the context for CRUD actions for movie nights.
  """
  import Ecto.Query

  alias Hanekawa.MovieNight
  alias Hanekawa.Repo

  require Logger

  @doc """
  A function to schedule movie nights. Checks to see that the date it's been given is valid
  and that the chosen date is later than the current day.
  """
  def schedule_movie_night(%{date: date_string} = attrs) do
    with {:ok, date} <- date_string_to_iso8601_date(date_string) do
      create_movie_night(%{attrs | date: date}) |> IO.inspect(label: "=======Context========")
    else
      err -> err
    end
  end

  @doc """
  Generic create function to insert movie night records
  """
  def create_movie_night(attrs) do
    %MovieNight{}
    |> MovieNight.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the next scheduled movie night
  """
  def get_next_movie_night() do
    today = Date.utc_today()

    MovieNight
    |> where([mn], mn.date >= ^today)
    |> order_by([mn], asc: mn.date)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
   Accepts an ISO8601 Date (i.e. 23-3-6) and returns a movie night if there is one scheduled for that date.
  """
  def get_movie_night_by_date(date) do
    case Repo.get_by(MovieNight, date: date) do
      nil ->
        {:error, "No movie night on that date"}

      movie_night ->
        {:ok, movie_night}
    end
  end

  @doc """
  Reschedules a movie night scheduled on the provided date with the newly provided date. Can also be used to update
  the movie title. Any associated reminders in the Oban queue will also be canceled.
  """
  def reschedule_movie_night(%{date: old_date_string, new_date: new_date_string} = attrs) do
    with {:ok, old_date} <- date_string_to_iso8601_date(old_date_string),
         {:ok, new_date} <- date_string_to_iso8601_date(new_date_string),
         :gt <- Date.compare(old_date, Date.utc_today()),
         {:ok, movie_night} <- get_movie_night_by_date(old_date),
         {:ok, _} <- cancel_movie_night_reminders(movie_night.id) do
      update_movie_night(movie_night, %{attrs | date: new_date})
    else
      :lt ->
        {:error, "cannot update past movie nights"}

      err ->
        err
    end
  end

  @doc """
  Generic update function for movie nights
  """
  def update_movie_night(movie_night, attrs) do
    movie_night
    |> MovieNight.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Accepts a date as a string and cancels a movie night scheduled on that day.
  This will also cancel any associated reminders in the Oban queue.
  """
  # Cancels a movie night on the given date.
  def cancel_movie_night(date_string) do
    with {:ok, date} <- date_string_to_iso8601_date(date_string),
         {:ok, movie_night} <- get_movie_night_by_date(date),
         {:ok, _} <- cancel_movie_night_reminders(movie_night.id) do
      delete_movie_night(movie_night)
    else
      err ->
        err
    end
  end

  @doc """
  Generic delete function for movie nights.
  """
  def delete_movie_night(movie_night) do
    Repo.delete(movie_night)
  end

  # Helper function for canceling reminder jobs in the Oban queue.
  # When a movie night is canceled or rescheduled we want to delete all queued reminders for that original date.
  defp cancel_movie_night_reminders(movie_night_id) do
    Oban.Job
    |> where([j], j.worker == "Hanekawa.MovieNight")
    |> where([j], j.args == ^%{movie_night_id: movie_night_id})
    |> Oban.cancel_all_jobs()
  end

  @doc """
  Helper function for converting a user provided string into a Date.
  """
  def date_string_to_iso8601_date(date_string) do
    with {:ok, date} <- Date.from_iso8601(date_string) do
      {:ok, date}
    else
      # If the string is already in ISO8601, return the Date, if not, try to format it.
      _ ->
        normalized_date_string = String.replace(date_string, "/", "-")

        [month, day, year] = String.split(normalized_date_string, "-")
        iso_date_string = input_to_iso_date_string(month, day, year)

        case Date.from_iso8601(iso_date_string) do
          {:ok, date} ->
            {:ok, date}

          err ->
            err
        end
    end
  end

  @doc """
  Helper function for returning a Date as a string in a more familiar format. (i.e. MM/DD/YYYY)
  """
  def date_to_mdy_string(date) do
    date_string = Date.to_string(date)

    [year, month, day] = String.split(date_string, "-")

    month <> "/" <> day <> "/" <> year
  end

  # Helper function for reformatting an input string to ISO8601
  defp input_to_iso_date_string(month, day, year) do
    full_year =
      case String.length(year) do
        2 ->
          "20" <> year

        _ ->
          year
      end

    full_month =
      case String.length(month) do
        1 ->
          "0" <> month

        _ ->
          month
      end

    full_day =
      case String.length(day) do
        1 ->
          "0" <> day

        _ ->
          day
      end

    "#{full_year}-#{full_month}-#{full_day}"
  end
end
