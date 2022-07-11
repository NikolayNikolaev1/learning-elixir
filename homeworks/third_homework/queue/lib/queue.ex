defmodule Queue do
  use GenServer

  def start_link(),
    do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def enqueue(elem),
    do: GenServer.cast(__MODULE__, {:enqueue, elem})

  def dequeue(),
    do: GenServer.call(__MODULE__, :dequeue)

  def init(args), do: {:ok, args}

  def handle_call(:dequeue, _from, []),
    do: {:reply, :empty, []}

  def handle_call(:dequeue, _from, [last]),
    do: {:reply, last, []}

  def handle_call(:dequeue, _from, [head | tail]),
    do: dequeue(tail, [head])

  def handle_cast({:enqueue, element}, state),
    do: {:noreply, [element | state]}

  defp dequeue([last], queue),
    do: {:reply, last, Enum.reverse(queue)}

  defp dequeue([head | tail], queue),
    do: dequeue(tail, [head | queue])
end
