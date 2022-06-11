defmodule FirstLab do
  def even_or_odd(list, type, multiplier) do
    mapped = Enum.map(list, fn x -> x * multiplier end)

    case type do
      :even ->
        Enum.filter(mapped, fn x -> rem(x, 2) === 0 end)

      :odd ->
        Enum.filter(mapped, fn x -> rem(x, 2) !== 0 end)

      _any ->
        :error
    end
  end

  # Return total letters count of every even/odd word from string.
  def letters_count(str, type) do
    words = String.split(str, " ")
    get_letters_count(words, type, 0)
  end

  # Return total count of letters.
  defp get_letters_count([], _type, letters_count),
    do: letters_count

  # Handle odd number of words.
  # Get the last word and returns total count of letters.
  defp get_letters_count([odd | []], :odd, letters_count),
    do: letters_count + String.length(odd)

  # Handle every even word.
  defp get_letters_count([_odd, even | words], :even, letters_count),
    do: get_letters_count(words, :even, letters_count + String.length(even))

  # Handle every odd word.
  defp get_letters_count([odd, _even | words], :odd, letters_count),
    do: get_letters_count(words, :odd, letters_count + String.length(odd))
end
