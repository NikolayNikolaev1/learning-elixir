defmodule Constants.ErrorMessage do
  def email_taken(email), do: "User with email #{email} already exists."

  def username_not_exist(username), do: "User with username #{username} does not exist."
end
