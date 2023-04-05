defmodule Hanekawa.InteractionCreate do
  alias Nostrum.Struct.{Interaction, User}
  alias Nostrum.Struct.Guild.Member
  alias Hanekawa.MovieNights

  def handle(%Interaction{data: %{name: "movienight"}} = interaction) do
    do_movie_night(interaction)
  end

  defp do_movie_night(%{options: [%{name: "schedule", options: [%{value: date}, %{value: movie_title}]}, member: %Member{user: %User{id: user_id}}]}) do
    case MovieNights.schedule_movie_night(%{date: date, movie_title: movie_title, creator_id: user_id}) do
      {:ok, movie_night} ->
        response = %{}
            # send response to server
      {:error, error} ->
        response = %{}
        # send repsonse to server
    end
  end

  defp do_movie_night(%{options: [%{name: "next"}]}) do
    MovieNights.get_next_movie_night()
  end

  defp do_movie_night(%{options: [%{name: "reschedule", options: [%{value: date}, %{value: new_date}, %{value: movie_title}]}]}) do
    MovieNights.reschedule_movie_night(%{date: date, new_date: new_date, movie_title: movie_title})
  end

  defp do_movie_night(%{options: [%{name: "cancel", options: [%{value: date}]}]}) do
    MovieNights.cancel_movie_night(date)
  end
end
