defmodule Greeter do
	def hello(names, lang_code \\ "en")

	def hello(names, lang_code) when is_list(names) do
		names = Enum.join(names, ", ")
		hello(names, lang_code)
	end
	def hello(name, lang_code) when is_binary(name),
		do: phrase(lang_code) <> name
	defp phrase("en"), do: "Hello, "
	defp phrase("es"), do: "Hola, "
end
