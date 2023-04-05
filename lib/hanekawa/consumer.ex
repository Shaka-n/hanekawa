defmodule Hanekawa.Consumer do
  use Nostrum.Consumer

  alias Hanekawa.Consumer.InteractionCreate
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    IO.inspect(interaction)
    InteractionCreate.handle(interaction)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    IO.inspect(msg, label: "Message Created")

    case msg.content do
      "!sleep" ->
        Api.create_message(msg.channel_id, "Going to sleep...")
        # This won't stop other events from being handled.
        Process.sleep(3000)

      "!baka" ->
        Api.create_message(msg.channel_id, "I-it's not like I like you or anything!~")

      "!hanabi" ->
        Api.create_message(msg.channel_id, "I love fireworks!")

      "!ping" ->
        Api.create_message(msg.channel_id, "Ouch! Quit throwing things!")

      "!raise" ->
        # This won't crash the entire Consumer.
        raise "No problems here!"

      _ ->
        :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
