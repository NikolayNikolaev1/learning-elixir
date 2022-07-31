defmodule Models.User do
  defstruct [
    :id,
    :username,
    :email,
    :password,
    :login_atempts,
    :last_login_atempt,
    :friend_list,
    :friend_requests
  ]

  def contains_friend_request?(user, fr_user_id) do
    fr_exist =
      Enum.filter(user.friend_requests, fn fr_connection ->
        fr_connection.user_id === fr_user_id
      end)

    do_contains(fr_exist)
  end

  def create(username, email, password) do
    id_num = Enum.random(1000..9999)
    id = "##{username}###{id_num}"

    %__MODULE__{
      id: id,
      username: username,
      email: email,
      password: password,
      login_atempts: 0,
      friend_list: [],
      friend_requests: []
    }
  end

  def find_by_email(users, email) do
    user =
      Enum.filter(users, fn user ->
        user.email === email
      end)

    do_find(user)
  end

  def find_by_id(users, id) do
    user =
      Enum.filter(users, fn user ->
        user.id === id
      end)

    do_find(user)
  end

  def find_by_username(users, username) do
    user =
      Enum.filter(users, fn user ->
        user.username === username
      end)

    do_find(user)
  end

  def has_friend?(user, friend_id) do
    friend_exist =
      Enum.filter(user.friend_list, fn fr_connection ->
        fr_connection.user_id === friend_id
      end)

    do_contains(friend_exist)
  end

  # Remove a user_id from the given friends/friend_requests list.
  def remove_from_fr_list(fr_list, user_id) do
    Enum.filter(fr_list, fn fr_connection ->
      fr_connection.user_id !== user_id
    end)
  end

  def update(users, [user_for_update]) do
    Enum.map(users, fn user ->
      if user.id === user_for_update.id, do: user_for_update, else: user
    end)
  end

  def update(users, [current | users_for_update]) do
    updated_users =
      Enum.map(users, fn user ->
        if user.id === current.id, do: current, else: user
      end)

    update(updated_users, users_for_update)
  end

  defp do_contains([]), do: false

  defp do_contains(_exists), do: true

  defp do_find([]), do: nil

  defp do_find([user]), do: user
end
