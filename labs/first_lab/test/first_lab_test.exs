defmodule FirstLabTest do
  use ExUnit.Case
  doctest FirstLab

  test "greets the world" do
    assert FirstLab.hello() == :world
  end
end
