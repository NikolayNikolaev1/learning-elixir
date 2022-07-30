defmodule UserAccounts do
  use GenServer
  alias Models.User, as: User

  def handle_call(:all, _from, users), do: {:reply, users, users}

  def handle_call({:login, email, password}, _from, user_accounts) do
    current_time = DateTime.utc_now()
    user = User.find_by_email(user_accounts, email)

    cond do
      user === nil ->
        {:reply, :user_not_found, user_accounts}

      user.login_atempts === 3 and DateTime.diff(current_time, user.last_login_atempt) < 60 ->
        {:reply, {:timeout, 60 - DateTime.diff(current_time, user.last_login_atempt)},
         user_accounts}

      user.password !== password ->
        login_atempts = rem(user.login_atempts, 3) + 1
        updated_user = %{user | login_atempts: login_atempts, last_login_atempt: current_time}
        {:reply, nil, User.update(user_accounts, [updated_user])}

      true ->
        {:reply, user, user_accounts}
    end
  end

  def handle_call({:register, username, email, password}, _from, user_accounts) do
    user = User.find_by_email(user_accounts, email)

    if user === nil do
      new_user = User.create(username, email, password)
      {:reply, new_user, [new_user | user_accounts]}
    else
      {:reply, :email_taken, user_accounts}
    end
  end

  def handle_call({:friend_all, user_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    {:reply, user.friend_list, user_accounts}
  end

  def handle_call({:friend_remove, user_id, friend_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    friend = User.find_by_id(user_accounts, friend_id)

    cond do
      friend === nil ->
        {:reply, :incorect_friend_id, user_accounts}

      true ->
        handle_user_friend_list = User.remove_from_fr_list(user.friend_list, friend_id)
        updated_user = %{user | friend_list: handle_user_friend_list}

        handle_friend_list = User.remove_from_fr_list(friend.friend_list, user_id)
        updated_friend = %{friend | friend_list: handle_friend_list}

        {:reply, :success, User.update(user_accounts, [updated_user, updated_friend])}
    end
  end

  def handle_call({:fr_all, user_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    {:reply, user.friend_requests, user_accounts}
  end

  def handle_call({:fr_send, from_user_id, to_user_id}, _from, user_accounts) do
    # from_user = User.find_by_id(user_accounts, from_user_id)
    to_user = User.find_by_id(user_accounts, to_user_id)

    cond do
      from_user_id === to_user_id ->
        {:reply, :fr_to_self, user_accounts}

      to_user === nil ->
        {:reply, :user_id_not_foud, user_accounts}

      User.contains_friend_request?(to_user, from_user_id) ->
        {:reply, :fr_exists, user_accounts}

      true ->
        updated_user = %{
          to_user
          | friend_requests: [%{user_id: from_user_id} | to_user.friend_requests]
        }

        {:reply, :success, User.update(user_accounts, [updated_user])}
    end
  end

  def handle_call({:get_mc_pid, from_user_id, to_user_id}, _from, user_accounts) do
    from_user = User.find_by_id(user_accounts, from_user_id)

    friend_list =
      Enum.filter(from_user.friend_list, fn fr_connection ->
        fr_connection.user_id === to_user_id
      end)

    if friend_list === [] do
      {:reply, :friend_not_found, user_accounts}
    else
      [friend] = friend_list
      {:reply, friend.mc_pid, user_accounts}
    end
  end

  def handle_cast({:fr_accept, user_id, request_user_id, mc_pid}, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    friend = User.find_by_id(user_accounts, request_user_id)

    handled_friend_requests = User.remove_from_fr_list(user.friend_requests, request_user_id)

    updated_user = %{
      user
      | friend_requests: handled_friend_requests,
        friend_list: [%{user_id: request_user_id, mc_pid: mc_pid} | user.friend_list]
    }

    updated_friend = %{
      friend
      | friend_list: [%{user_id: user_id, mc_pid: mc_pid} | friend.friend_list]
    }

    {:noreply, User.update(user_accounts, [updated_user, updated_friend])}
  end

  def handle_cast({:fr_decline, user_id, request_user_id}, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)

    handled_friend_requests = User.remove_from_fr_list(user.friend_requests, request_user_id)

    updated_user = %{user | friend_requests: handled_friend_requests}

    {:noreply, User.update(user_accounts, [updated_user])}
  end

  def init(args), do: {:ok, args}

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
end
