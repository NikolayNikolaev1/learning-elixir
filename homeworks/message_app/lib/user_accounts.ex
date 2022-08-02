# Module stores all registered users in state.
defmodule UserAccounts do
  use GenServer
  alias Models.User, as: User

  def handle_call(:all, _from, users), do: {:reply, users, users}

  # Remove user_id from friend requests and add it to friend list.
  def handle_call({:fr_accept, user_id, request_user_id, mc_pid}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    friend = User.find_by_id(user_accounts, request_user_id)
    friend_request_exist = User.contains_friend_request?(user, request_user_id)

    cond do
      user === nil ->
        {:reply, {:user_not_found, user_id}, user_accounts}

      friend === nil ->
        {:reply, {:user_not_found, request_user_id}, user_accounts}

      !friend_request_exist ->
        {:reply, :fr_not_found, user_accounts}

      true ->
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

        {:reply, :success, User.update(user_accounts, [updated_user, updated_friend])}
    end
  end

  # Return a list of all sent friend requests to user.
  def handle_call({:fr_all, user_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    {:reply, user.friend_requests, user_accounts}
  end

  # Remove friend request from list without adding to friend list.
  def handle_call({:fr_decline, user_id, request_user_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    request_user = User.find_by_id(user_accounts, request_user_id)
    friend_request_exist = User.contains_friend_request?(user, request_user_id)

    cond do
      user === nil ->
        {:reply, {:user_not_found, user_id}, user_accounts}

      request_user === nil ->
        {:reply, {:user_not_found, request_user_id}, user_accounts}

      !friend_request_exist ->
        {:reply, :fr_not_found, user_accounts}

      true ->
        handled_friend_requests = User.remove_from_fr_list(user.friend_requests, request_user_id)
        updated_user = %{user | friend_requests: handled_friend_requests}

        {:reply, :success, User.update(user_accounts, [updated_user])}
    end
  end

  # Adds from_user_id to other's user friend request list.
  def handle_call({:fr_send, from_user_id, to_user_id}, _from, user_accounts) do
    from_user = User.find_by_id(user_accounts, from_user_id)
    to_user = User.find_by_id(user_accounts, to_user_id)

    cond do
      from_user_id === to_user_id ->
        {:reply, :equal_ids, user_accounts}

      from_user === nil ->
        {:reply, {:user_not_found, from_user_id}, user_accounts}

      to_user === nil ->
        {:reply, {:user_not_found, to_user_id}, user_accounts}

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

  # Returns list of all friend of user.
  def handle_call({:friend_all, user_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    {:reply, user.friend_list, user_accounts}
  end

  # Remove user ids from both user's friend lists.
  def handle_call({:friend_remove, user_id, friend_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    friend = User.find_by_id(user_accounts, friend_id)
    has_friend = User.has_friend?(user, friend_id)

    cond do
      user === nil ->
        {:reply, {:user_not_found, user_id}, user_accounts}

      friend === nil ->
        {:reply, {:user_not_found, friend_id}, user_accounts}

      !has_friend ->
        {:reply, :friend_not_found, user_accounts}

      true ->
        handle_user_friend_list = User.remove_from_fr_list(user.friend_list, friend_id)
        updated_user = %{user | friend_list: handle_user_friend_list}

        handle_friend_list = User.remove_from_fr_list(friend.friend_list, user_id)
        updated_friend = %{friend | friend_list: handle_friend_list}

        {:reply, :success, User.update(user_accounts, [updated_user, updated_friend])}
    end
  end

  # Return list of all mc_pids for given user_id.
  def handle_call({:get_all_mc_pids, user_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)

    cond do
      user === nil ->
        {:reply, {:user_not_found, user_id}, user_accounts}

      user.friend_list === [] ->
        {:reply, :no_friends, user_accounts}

      true ->
        mc_pid_list = Enum.map(user.friend_list, fn fr_connection -> fr_connection.mc_pid end)
        {:reply, {:success, mc_pid_list}, user_accounts}
    end
  end

  # Return the MessageClient pid for given user ids.
  def handle_call({:get_mc_pid, user_id, friend_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    friend = User.find_by_id(user_accounts, friend_id)
    has_friend = User.has_friend?(user, friend_id)

    cond do
      user === nil ->
        {:reply, {:user_not_found, user_id}, user_accounts}

      friend === nil ->
        {:reply, {:user_not_found, friend_id}, user_accounts}

      !has_friend ->
        {:reply, :friend_not_found, user_accounts}

      true ->
        friend_list =
          Enum.filter(user.friend_list, fn fr_connection ->
            fr_connection.user_id === friend_id
          end)

        [friend] = friend_list
        {:reply, {:success, friend.mc_pid}, user_accounts}
    end
  end

  # Find user from state if exists and return him to the client.
  def handle_call({:login, email, password}, _from, user_accounts) do
    current_time = DateTime.utc_now()
    user = User.find_by_email(user_accounts, email)

    cond do
      user === nil ->
        {:reply, :user_not_found, user_accounts}

      # After 3 consequitive wrong attempts to login, the login is locked for 1 minute.
      user.login_atempts === 3 and DateTime.diff(current_time, user.last_login_atempt) < 60 ->
        {:reply, {:timeout, 60 - DateTime.diff(current_time, user.last_login_atempt)},
         user_accounts}

      user.password !== password ->
        login_atempts = rem(user.login_atempts, 3) + 1
        updated_user = %{user | login_atempts: login_atempts, last_login_atempt: current_time}
        {:reply, nil, User.update(user_accounts, [updated_user])}

      true ->
        {:reply, {:success, user}, user_accounts}
    end
  end

  # Create new user and add him to the state.
  def handle_call({:register, username, email, password}, _from, user_accounts) do
    user = User.find_by_email(user_accounts, email)

    if user === nil do
      new_user = User.create(username, email, password)
      {:reply, {:success, new_user}, [new_user | user_accounts]}
    else
      {:reply, :email_taken, user_accounts}
    end
  end

  def init(args), do: {:ok, args}

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
end
