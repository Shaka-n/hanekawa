defmodule Hanekawa.ConsumerSupervisor do
  @moduledoc """
  Supervises Hanekawa's consumers.

  Per the Nostrum documentation, this spawns one consumer per CPU,
  which can be found from the number of schedulers online.
  """

  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children =
      for n <- 1..System.schedulers_online(),
          do: Supervisor.child_spec({Hanekawa.Consumer, []}, id: {:hanekawa, :consumer, n})

    Supervisor.init(children, strategy: :one_for_one)
  end
end
