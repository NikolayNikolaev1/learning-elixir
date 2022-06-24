defmodule SecondHomework do
  # 1. Find the last element of a list.
  def last([]), do: []
  def last([next]), do: next
  def last([_next | list]), do: last(list)
  # 2. Find the K'th element of a list. The first element in the list is number 1.
  def nth([], num) when num >= 1, do: nil
  def nth([next | _list], 1), do: next
  def nth([_next | list], num), do: nth(list, num - 1)
  # 3. Find the number of elements of a list.
  def length([]), do: 0
  def length(list), do: length(list, 0)
  def length([], count), do: count
  def length([_next | list], count), do: length(list, count + 1)
  # 4. Reverse a list.
  def reverse([]), do: []
  def reverse(list), do: reverse(list, [])
  def reverse([], reversed), do: reversed
  def reverse([next | list], reversed), do: reverse(list, [next | reversed])
  # 5. Flatten a nested list structure.
  def flatten(list), do: List.flatten(list)
  # 6. Eliminate consecutive duplicates of list elements.
  def compress(str) do
    list = String.graphemes(str)
    [next | _] = list
    compress(list, [next])
  end

  def compress([last], [last | compressed]), do: compress([last | compressed], "")
  def compress([next], [_last | _compressed] = list), do: compress([next | list], "")
  def compress([next | list], [next | compressed]), do: compress(list, [next | compressed])
  def compress([next | list], [_last | _compressed] = list), do: compress(list, [next | list])
  def compress([last], str), do: last <> str
  def compress([next | list], str), do: compress(list, next <> str)
end
