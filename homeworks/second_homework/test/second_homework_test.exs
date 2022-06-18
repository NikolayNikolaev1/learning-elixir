defmodule SecondHomeworkTest do
  use ExUnit.Case
  doctest SecondHomework

  test "greets the world" do
    assert SecondHomework.hello() == :world
  end
end
