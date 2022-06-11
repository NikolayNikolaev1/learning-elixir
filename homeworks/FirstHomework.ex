defmodule FirstHomework do
  def filter_str(str, letter) do
    words = String.split(str, " ")
    filter_str(words, letter, "")
  end

  defp filter_str([], _letter, filtered_words), do: filtered_words

  defp filter_str([next | words], letter, filtered_words) do
    if String.starts_with?(next, letter) do
      filter_str(words, letter, filtered_words)
    else
      filter_str(words, letter, filtered_words <> " " <> next)
    end
  end

  # Reverse words from given string.
  def reversed(str) do
    words = String.split(str, " ")
    [next | _] = words
    reversed(words, next)
  end

  # Returns the reversed string when there are no other words left.
  defp reversed([], reversed_words),
    do: reversed_words

  defp reversed([next | words], reversed_words),
    do: reversed(words, "#{next} " <> reversed_words)
end
