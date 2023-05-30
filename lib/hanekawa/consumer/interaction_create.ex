defmodule Hanekawa.Consumer.InteractionCreate do
  @moduledoc """
    This module holds the context for Interaction Create events from the Discord API.
    In other words, this is where we handle logic for slash commands input from users.
  """
  alias Nostrum.Api
  alias Nostrum.Struct.Interaction
  alias Hanekawa.MovieNights
  alias Hanekawa.Utils

  require Logger

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
            "Movie night scheduled! We're watching #{movie_night.movie_title} on #{MovieNights.date_to_mdy_string(movie_night.date)}! (That's a #{Utils.date_day_of_week_to_string(movie_night.date)})"
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)

      {:error, error} ->
        Logger.error("There was a problem scheduling this movie night.")
        Api.create_interaction_response(interaction.id, interaction.token, error_response(error))
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
        IO.inspect(movie_night, label: "=======Handler=======")

        response =
          message_response(
            "Movie night scheduled! We're watching something on #{MovieNights.date_to_mdy_string(movie_night.date)}! (That's a #{Utils.date_day_of_week_to_string(movie_night.date)})"
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)

      {:error, error} ->
        Logger.error(%{error: error})
        Api.create_interaction_response(interaction.id, interaction.token, error_response(error))
    end
  end

  def do_movie_night(interaction, :next) do
    case MovieNights.get_next_movie_night() do
      nil ->
        response = message_response("Whoops! We don't have any movie nights scheduled!")
        Api.create_interaction_response(interaction.id, interaction.token, response)

      movie_night ->
        title_string =
          case movie_night.movie_title do
            nil ->
              "We haven't picked a movie yet."

            title ->
              "We decided to watch #{title}."
          end

        response =
          message_response(
            "The next movie night is scheduled for #{MovieNights.date_to_mdy_string(movie_night.date)} (That's a #{Utils.date_day_of_week_to_string(movie_night.date)}). #{title_string}"
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)
    end
  end

  def do_movie_night(
        %Interaction{data: %{options: [%{options: [%{value: date}, %{value: new_date}]}]}} =
          interaction,
        :reschedule
      ) do
    case MovieNights.change_movie_night_date_and_title(%{date: date, new_date: new_date}) do
      {:ok, movie_night} ->
        response =
          message_response(
            "Movie night scheduled! We're watching #{movie_night.movie_title} on #{movie_night.date}!"
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)

      {:error, error} ->
        Logger.error("There was a problem rescheduling this movie night.")
        Api.create_interaction_response(interaction.id, interaction.token, error_response(error))
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
    case MovieNights.change_movie_night_date_and_title(%{
           date: date,
           new_date: new_date,
           movie_title: movie_title
         }) do
      {:ok, movie_night} ->
        response =
          message_response(
            "Movie night scheduled! We're watching #{movie_night.movie_title} on #{MovieNights.date_to_mdy_string(movie_night.date)}!"
          )

        Api.create_interaction_response(interaction.id, interaction.token, response)

      {:error, error} ->
        Logger.error("There was a problem rescheduling this movie night.")
        Api.create_interaction_response(interaction.id, interaction.token, error_response(error))
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

      {:error, error} ->
        Logger.error("There was a problem canceling this movie night.")
        Api.create_interaction_response(interaction.id, interaction.token, error_response(error))
    end
  end

  defp error_response(error) do
    errors =
      Ecto.Changeset.traverse_errors(error, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%#{key}", to_string(value))
        end)
      end)

    error_msg =
      errors
      |> Enum.map(fn {key, errors} -> "#{key}: #{Enum.join(errors, ", ")}" end)
      |> Enum.join("\n")

    message_response(
      "There was a problem processing your request. We found this error message: #{error_msg}"
    )
  end

  defp message_response(content) do
    %{
      type: 4,
      data: %{content: content}
    }
  end
end
