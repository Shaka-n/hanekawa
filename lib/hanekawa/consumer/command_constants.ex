defmodule Hanekawa.CommandConstants do
  @moduledoc """
  Module for creating list of available commands at compile time.
  Reduces compile time dependencies.
  Allows for ensuring commands map to existing atoms in the application,
  in theory providing guards against conflicting slash commands created by other bots.
  """
  @commands %{
    movie_night: [:schedule, :reschedule, :next, :cancel]
  }

  def commands_list() do
    @commands
  end
end
