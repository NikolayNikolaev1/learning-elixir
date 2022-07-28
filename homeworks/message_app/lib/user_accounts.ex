defmodule UserAccounts do
  use GenServer
  alias Constants.ErrorMessage, as: ErrorMessage
  alias MessageApp
  alias Models.User, as: User

  def get_all(), do: GenServer.call(__MODULE__, :all)

  def init(args), do: {:ok, args}

  def login(email, password) do
    response = GenServer.call(__MODULE__, {:login, email, password})

    case response do
      :user_not_found ->
        ErrorMessage.email_not_found(email)

      {:timeout, timeout} ->
        ErrorMessage.login_timeout(email, timeout)

      nil ->
        ErrorMessage.incorect_credentials()

      user ->
        "Welcome, #{user.username}!"
        user
    end
  end

  def register(username, email, password) do
    response = GenServer.call(__MODULE__, {:register, username, email, password})

    case response do
      :email_taken ->
        ErrorMessage.email_taken(email)

      user ->
        "Welcome, #{user.username}!"
        user
    end
  end

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

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
        {:reply, nil, User.update(user_accounts, updated_user)}

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

  def handle_call({:fl_all, user_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    {:reply, user.friend_list, user_accounts}
  end

  def handle_call({:fr_all, user_id}, _from, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    {:reply, user.friend_requests, user_accounts}
  end

  def handle_call({:fr_send, from_user_id, to_user_id}, _from, user_accounts) do
    from_user = User.find_by_id(user_accounts, from_user_id)
    to_user = User.find_by_id(user_accounts, to_user_id)

    cond do
      from_user.id === to_user_id ->
        {:reply, :fr_to_self, user_accounts}

      to_user === nil ->
        {:reply, :user_id_not_foud, user_accounts}

      User.contains_friend_request?(to_user, from_user) ->
        {:reply, :fr_exists, user_accounts}

      true ->
        updated_user = %{to_user | friend_requests: [from_user | to_user.friend_requests]}
        {:reply, :success, User.update(user_accounts, updated_user)}
    end
  end

  def handle_cast({:fr_accept, user_id, request_user_id}, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)
    new_friend = User.find_by_id(user_accounts, request_user_id)

    handled_friend_requests =
      Enum.filter(user.friend_requests, fn fr -> fr.id !== request_user_id end)

    updated_user = %{
      user
      | friend_requests: handled_friend_requests,
        friend_list: [new_friend | user.friend_list]
    }

    {:noreply, User.update(user_accounts, updated_user)}
  end

  def handle_cast({:fr_decline, user_id, request_user_id}, user_accounts) do
    user = User.find_by_id(user_accounts, user_id)

    handled_friend_requests =
      Enum.filter(user.friend_requests, fn fr -> fr.id !== request_user_id end)

    updated_user = %{user | friend_requests: handled_friend_requests}

    {:noreply, User.update(user_accounts, updated_user)}
  end
end
