defmodule Example.Greetings do
  @greeting "Hello"
  def morning(name), do: "Good morning, #{name}."
  def evening(name), do: "Good evening, #{name}."
  def greeting(name), do: ~s(#{@greeting}, #{name}.)
end

defmodule Example.User do
  @derive {Inspect, only: [:name]}
  defstruct name: "Sean", roles: []
end
