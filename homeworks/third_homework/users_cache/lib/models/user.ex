defmodule Models.User do
  defstruct [:username, :avatar_url, :bio, :created_at, :email, :id]

  def contains([], _username),
    do: false

  # def contains([user], username),
  #   do: contains([], username, user.username)

  def contains([next | users], username),
    do: contains(users, username, next.username)

  defp contains(_users, username, username),
    do: true

  defp contains([], _username, _curr_username),
    do: false

  defp contains([next | users], username, _curr_username),
    do: contains(users, username, next.username)
end
