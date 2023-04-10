defmodule Hanekawa.Consumer.InteractionCreate do
  alias Nostrum.Api
  alias Nostrum.Struct.Interaction
  alias Hanekawa.MovieNights

  require Logger

  @commands [
    :schedule,
    :reschedule,
    :next,
    :cancel
  ]

  def handle(
        %Interaction{data: %{name: "movienight", options: [%{name: subcommand}]}} = interaction
      ) do
    with atom_subcommand <- String.to_existing_atom(subcommand) do
      IO.inspect(interaction)
      do_movie_night(interaction, atom_subcommand)
    end
  end

  def do_movie_night(
        %Interaction{data: %{options: [%{options: [%{value: date}, %{value: movie_title}]}]}} =
          interaction,
        :schedule
      ) do
    creator_id = Integer.to_string(interaction.user.id)
    channel_id = Integer.to_string(interaction.channel_id)

    case MovieNights.schedule_movie_night(%{
           date: date,
           movie_title: movie_title,
           creator_id: creator_id,
           channel_id: channel_id
         }) do
      {:ok, movie_night} ->
        response =
          message_response(
            "Movie night scheduled! We're watching #{movie_night.movie_title} on #{MovieNights.date_to_mdy_string(movie_night.date)}!"
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)

      {:error, _error} ->
        Logger.error("There was a problem scheduling this movie night.")
        Api.create_interaction_response(interaction.id, interaction.token, error_response())
    end
  end

  def do_movie_night(
        %Interaction{data: %{options: [%{options: [%{value: date}]}]}} = interaction,
        :schedule
      ) do
    creator_id = Integer.to_string(interaction.user.id)
    channel_id = Integer.to_string(interaction.channel_id)

    case MovieNights.schedule_movie_night(%{
           date: date,
           creator_id: creator_id,
           channel_id: channel_id
         }) do
      {:ok, movie_night} ->
        response =
          message_response(
            "Movie night scheduled! We're watching something on #{MovieNights.date_to_mdy_string(movie_night.date)}!"
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)

      {:error, _error} ->
        Logger.error("There was a problem scheduling this movie night.")
        Api.create_interaction_response(interaction.id, interaction.token, error_response())
    end
  end

  def do_movie_night(interaction, :next) do
    case MovieNights.get_next_movie_night() do
      nil ->
        response = message_response("Whoops! We don't have any movie nights scheduled!")
        Api.create_interaction_response(interaction.id, interaction.token, response)

      movie_night ->
        response =
          message_response(
            "The next movie night is scheduled for #{MovieNights.date_to_mdy_string(movie_night.date)}. We decided on #{movie_night.movie_title}"
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)
    end
  end

  def do_movie_night(
        %Interaction{data: %{options: [%{options: [%{value: date}, %{value: new_date}]}]}} =
          interaction,
        :reschedule
      ) do
    case MovieNights.reschedule_movie_night(%{date: date, new_date: new_date}) do
      {:ok, movie_night} ->
        response =
          message_response(
            "Movie night scheduled! We're watching #{movie_night.movie_title} on #{movie_night.date}! "
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)

      {:error, _error} ->
        Logger.error("There was a problem rescheduling this movie night.")
        Api.create_interaction_response(interaction.id, interaction.token, error_response())
    end
  end

  def do_movie_night(
        %Interaction{
          data: %{
            options: [%{options: [%{value: date}, %{value: new_date}, %{value: movie_title}]}]
          }
        } = interaction,
        :reschedule
      ) do
    case MovieNights.reschedule_movie_night(%{
           date: date,
           new_date: new_date,
           movie_title: movie_title
         }) do
      {:ok, movie_night} ->
        response =
          message_response(
            "Movie night scheduled! We're watching #{movie_night.movie_title} on #{MovieNights.date_to_mdy_string(movie_night.date)}! "
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)

      {:error, _error} ->
        Logger.error("There was a problem rescheduling this movie night.")
        Api.create_interaction_response(interaction.id, interaction.token, error_response())
    end
  end

  def do_movie_night(
        %Interaction{data: %{options: [%{options: [%{value: date}]}]}} = interaction,
        :cancel
      ) do
    case MovieNights.cancel_movie_night(date) do
      {:ok, movie_night} ->
        response =
          message_response(
            "The movie night on " <>
              MovieNights.date_to_mdy_string(movie_night.date) <> " has been canceled."
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)

      {:error, _error} ->
        Logger.error("There was a problem canceling this movie night.")
        Api.create_interaction_response(interaction.id, interaction.token, error_response())
    end
  end

  defp error_response() do
    message_response("There was a problem scheduling your movie.")
  end

  defp message_response(content) do
    %{
      type: 4,
      data: %{content: content}
    }
  end

  defp interaction_commands() do
    @commands
  end
end
