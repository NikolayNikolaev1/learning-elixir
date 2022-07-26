defmodule SecondLabTest do
  use ExUnit.Case
  doctest SecondLab

  test "greets the world" do
    assert SecondLab.hello() == :world
  end
end
