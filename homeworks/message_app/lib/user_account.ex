defmodule UserAccount do
  use GenServer
  alias Models.User, as: User
  alias Constants.ErrorMessage, as: ErrorMessage

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
    end
  end

  def register(username, email, password) do
    response = GenServer.cast(__MODULE__, {:register, username, email, password})

    case response do
      :email_taken ->
        ErrorMessage.email_taken(email)

      user ->
        "Welcome, #{user.username}!"
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

  def handle_call({:register, username, email, password}, user_accounts) do
    user = User.find_by_email(user_accounts, email)

    if user === nil do
      new_user = User.create(username, email, password)
      {:reply, new_user, [new_user | user_accounts]}
    else
      {:reply, :email_taken, user_accounts}
    end
  end
end
