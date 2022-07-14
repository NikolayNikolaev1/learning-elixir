defmodule Models.User do
  defstruct [
    :username,
    :avatar_url,
    :bio,
    :created_at,
    :email,
    :id,
    :cached_at
  ]

  # Returns user if exists, otherwise returns nil.
  def find(users, username) do
    user = Enum.filter(users, fn user -> user.username === username end)
    do_find(user)
  end

  # Checks if user cache is old.
  def old_cache?(%__MODULE__{cached_at: cached_at}, cached_time) do
    cached_from = DateTime.diff(DateTime.utc_now(), cached_at, :millisecond)
    do_old_cache?(cached_from, cached_time)
  end

  # Update user in given list.
  def update(users, new_user) do
    Enum.map(users, fn user ->
      if user.username === new_user.username, do: new_user, else: user
    end)
  end

  defp do_find([]), do: nil

  defp do_find([user]), do: user

  defp do_old_cache?(cached_from, cache_time) when cached_from <= cache_time, do: true

  defp do_old_cache?(cached_from, cache_time) when cached_from > cache_time, do: false
end
