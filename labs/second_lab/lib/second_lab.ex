defmodule SecondLab do
  defguard is_even(num) when rem(num, 2) === 0

  def hh({a, _b}) when is_even(a) do
    my_fn = fn
      {1, b} when is_even(b) -> 1 + b
      {a, 1} -> a + 1
    end

    my_fn.(a)
  end

  def hh({_a, b}) do
    case b do
      even when is_even(even) -> "even"
      _ -> "odd"
    end

    cond do
      # b when is_even(b) -> "even"
      true -> "odd"
    end
  end

  def hh({_a, _b, _c}, _d \\ 10) do
    # do stuff
  end

  def test(1, b) when is_even(b), do: 1 + b
  def test(a, 1) when is_even(a), do: a + 1
end
