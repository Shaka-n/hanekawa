defmodule Hanekawa.Workers.CheckMovieNight do
  @moduledoc """
  This module defines an Oban worker which runs every day at midnight to check if a reminder job should be queued.
  """
  use Oban.Worker, queue: :default, max_attempts: 1

  alias Hanekawa.Workers.MovieNight
  alias Hanekawa.Utils

  # Runs every day at midnight
  @impl Oban.Worker
  def perform(%Oban.Job{args: %{}}) do
    movie_night = Hanekawa.MovieNights.get_next_movie_night()
    movie_night_date_day_string = Utils.date_day_of_week_to_string(movie_night.date)
    today = Date.utc_today()

    weekly_movie_title_string =
      if movie_night.movie_title do
        "We're watching #{movie_night.movie_title} on " <> movie_night_date_day_string
      else
        "We haven't decided what we're watching yet, but movie night is on " <>
          movie_night_date_day_string
      end

    daily_movie_title_string =
      if movie_night.movie_title do
        "We're watching #{movie_night.movie_title}!"
      else
        "We haven't decided what we're watching!"
      end

    this_week? =
      today
      |> Date.end_of_week()
      |> Date.compare(movie_night.date)

    reminder_message =
      if Date.day_of_week(today) == 1 do
        "This is a movie night week! " <> weekly_movie_title_string
      else
        "Movie night is tonight! " <> daily_movie_title_string
      end

    case this_week? do
      :lt ->
        nil

      _ ->
        %{
          movie_night_id: movie_night.id,
          reminder_message: reminder_message,
          channel_id: movie_night.channel_id
        }
        |> MovieNight.new()
        |> Oban.insert()
    end
  end
end
