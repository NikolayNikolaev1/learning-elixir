defmodule UsersCacheTest do
  use ExUnit.Case
  doctest UsersCache

  test "greets the world" do
    assert UsersCache.hello() == :world
  end
end
