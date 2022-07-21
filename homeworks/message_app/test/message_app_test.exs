defmodule MessageAppTest do
  use ExUnit.Case
  doctest MessageApp

  test "greets the world" do
    assert MessageApp.hello() == :world
  end
end
