defmodule Greeter1 do
	def hello(%{name: person_name} = person) do
		IO.puts("Hello, " <> person_name)
		IO.inspect(person)
	end
end
		
