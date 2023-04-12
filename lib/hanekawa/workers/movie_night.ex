defmodule Hanekawa.Workers.MovieNight do
  @moduledoc """
  Sends messages to Discord every day at noon.
  """
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{
        args:
          %{
            movie_night_id: _movie_night_id,
            reminder_message: reminder_message,
            channel_id: channel_id
          } = _args
      }) do
    Nostrum.Api.create_message(channel_id, reminder_message)
  end
end
