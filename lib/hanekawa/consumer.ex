defmodule Hanekawa.Consumer do
  @moduledoc """
    This module defines the consumer agent that acts as a gateway event handler for
    events passed from the Discord WebSocket connection.
  """
  use Nostrum.Consumer

  alias Hanekawa.Consumer.InteractionCreate
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    InteractionCreate.handle(interaction)
  end

  # This is just meant to verify that the connection is working as expected.
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    # IO.inspect(msg)
    case msg.content do
      "!ping" ->
        Api.create_message(msg.channel_id, "pong!")

      "!pong" ->
        Api.create_message(msg.channel_id, "ping!")

      "!raise" ->
        # This won't crash the entire Consumer.
        raise "No problems here!"

      "!hello" ->
        Api.create_message(msg.channel_id, "Hello! My name is Hanekawa. It's nice to meet you.")

      "!thankyou" ->
        Api.create_message(
          msg.channel_id,
          "You're welcome #{msg.member.nick}!"
        )

      _ ->
        :ignore
    end
  end

  # Default event handler. Consumer will crash if given an event it hasn't been told explicitly how to handle.
  def handle_event(_event) do
    :noop
  end
end
