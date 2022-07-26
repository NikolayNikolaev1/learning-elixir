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

  def contains_friend_request?(user, fr_user) do
    fr_exist = Enum.filter(user.friend_requests, fn fr -> fr === fr_user end)
    do_contains(fr_exist)
  end

  def find_by_email(users, email) do
    user = Enum.filter(users, fn user -> user.email === email end)
    do_find(user)
  end

  def find_by_id(users, id) do
    user = Enum.filter(users, fn user -> user.id === id end)
    do_find(user)
  end

  def find_by_username(users, username) do
    user = Enum.filter(users, fn user -> user.username === username end)
    do_find(user)
  end

  def update(users, updated_user) do
    Enum.map(users, fn user ->
      if user.id === updated_user.id, do: updated_user, else: user
    end)
  end

  defp do_contains([]), do: false

  defp do_contains(_exists), do: true

  defp do_find([]), do: nil

  defp do_find([user]), do: user
end
