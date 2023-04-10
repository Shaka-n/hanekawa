defmodule Hanekawa.Utils do
  def date_day_of_week_to_string(date) do
    case Date.day_of_week(date) do
      1 ->
        "Monday"

      2 ->
        "Tuesday"

      3 ->
        "Wednesday"

      4 ->
        "Thursday"

      5 ->
        "Friday"

      6 ->
        "Saturday"

      7 ->
        "Sunday"
    end
  end
end
