defmodule UserAccount do
  use GenServer
  alias Models.User, as: User
  alias Constants.ErrorMessage, as: ErrorMessage

  def get_all(), do: GenServer.call(__MODULE__, :all)

  def init(args), do: {:ok, args}

  def login(username, password) do
    users = get_all()
    user_exists = User.find_by_username(users, username)
    do_login(user_exists, {:credentials, username, password})
  end

  def register(username, email, password) do
    users = get_all()
    user_exists = User.find_by_email(users, email)
    do_register(user_exists, {:credentials, username, email, password})
  end

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def handle_call(:all, _from, users), do: {:reply, users, users}

  def handle_call({:login, user, password}, user_accounts) do
    if user.password === password do
      {:reply, user, user_accounts}
    else
      updated_user = %{user | login_atempts: user.login_atempts + 1}
      {:reply, nil, User.update(user_accounts, updated_user)}
    end
  end

  def handle_cast({:register, {:credentials, username, email, password}}, user_accounts) do
    new_user = User.create(username, email, password)
    {:noreply, [new_user | user_accounts]}
  end

  defp do_login(nil, {:credentials, username, _password}) do
    ErrorMessage.username_not_exist(username)
  end

  defp do_login(user, {:credentials, _username, password}) do
    GenServer.call(__MODULE__, {:login, user, password})
  end

  defp do_register(nil, credentials) do
    GenServer.cast(__MODULE__, {:register, credentials})
  end

  defp do_register(_user, {:credentials, _username, email, _password}) do
    ErrorMessage.email_taken(email)
  end
end
