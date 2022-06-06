defmodule Greeter2 do
	def hello(), do: "Hello, anonymous person!"	# hello/0
	def hello(name), do: "Hello, #{name}!"		# hello/1
	def hello(first_name, last_name), 
		do: "Hello, #{first_name} #{last_name}!"#hello/2
end
