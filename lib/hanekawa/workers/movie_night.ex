defmodule Hanekawa.Workers.MovieNight do
  use Oban.Worker, queue: :default

  # Sends reminder messages to Discord.
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
