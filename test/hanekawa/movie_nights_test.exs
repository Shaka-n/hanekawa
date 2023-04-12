defmodule Hanekawa.MovieNightsTest do
  use Hanekawa.DataCase, async: true
  use Oban.Testing, repo: Hanekawa.Repo

  alias Hanekawa.{MovieNight, MovieNights}
  alias Hanekawa.MovieNightFixtures

  describe "schedule_movie_night/1" do
    test "creates a movie night given a date" do
      {:ok, movie_night} = MovieNights.schedule_movie_night(%{date: "3/6/99"})

      assert %MovieNight{} = movie_night
    end

    test "accepts ISO8601 formatted dates" do
      {:ok, movie_night} = MovieNights.schedule_movie_night(%{date: "2055-03-06"})

      assert %MovieNight{} = movie_night
    end

    test "will prevent double booking movie nights" do
      {:ok, _movie_night} = MovieNights.schedule_movie_night(%{date: "2055-03-06"})
      {result, _} = MovieNights.schedule_movie_night(%{date: "2055-03-06"})
      assert result == :error
    end

    test "will not accept dates in the past" do
      {result, _} = MovieNights.schedule_movie_night(%{date: "2000-03-06"})
      assert result == :error
    end

    test "accepts and persists a movie title and creator id" do
      {:ok, movie_night} =
        MovieNights.schedule_movie_night(%{
          date: "3/6/99",
          creator_id: "1234567890",
          movie_title: "The Wizard SoSo"
        })

      assert movie_night.movie_title == "The Wizard SoSo"
      assert movie_night.creator_id == "1234567890"
    end
  end

  describe "get_next_movie_night/0" do
    test "gets the movie night whose date is closest to today's date" do
      today = Date.utc_today()
      tomorrow = Date.add(today, 1)
      day_after_tomorrow = Date.add(today, 2)

      {:ok, next_movie_night} =
        MovieNights.schedule_movie_night(%{date: Date.to_string(tomorrow)})

      MovieNights.schedule_movie_night(%{date: Date.to_string(day_after_tomorrow)})

      result = MovieNights.get_next_movie_night()

      assert next_movie_night.date == result.date
    end
  end

  describe "get_movie_night_by_date/1" do
    test "accepts a date as a string and gets the corresponding movie night if it exists" do
      movie_night = MovieNightFixtures.movie_night_fixture()
      {:ok, result} = MovieNights.get_movie_night_by_date(movie_night.date)

      assert result.date == movie_night.date
    end
  end

  describe "reschedule_movie_night/2" do
    test "updates an existing movie night with a new date and attrs" do
      today = Date.utc_today()
      day_after_tomorrow = Date.add(today, 2)
      %{date: original_date} = MovieNightFixtures.movie_night_fixture()

      {:ok, result} =
        MovieNights.reschedule_movie_night(%{
          date: Date.to_string(original_date),
          new_date: Date.to_string(day_after_tomorrow),
          creator_id: "0987654321",
          movie_title: "Lawnmower Man"
        })

      assert result.date == day_after_tomorrow
      assert result.movie_title == "Lawnmower Man"
      assert result.creator_id == "0987654321"
    end
  end

  describe "cancel_movie_night/1" do
    test "accepts a date as a string and cancels a movie night" do
      %{date: original_date} = MovieNightFixtures.movie_night_fixture()
      {result, _} = MovieNights.cancel_movie_night(Date.to_string(original_date))

      assert result == :ok
    end
  end

  describe "date_string_to_iso8601_date/1" do
    test "accepts a date as a string separated by dashes or forward slashes and returns a date" do
      {:ok, date} = MovieNights.date_string_to_iso8601_date("2055-03-06")

      assert ~D[2055-03-06] == date
    end
  end
end
