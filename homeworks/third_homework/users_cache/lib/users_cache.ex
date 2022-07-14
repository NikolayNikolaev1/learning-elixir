defmodule UsersCache do
  use GenServer
  alias Models.User, as: User
  @url "https://api.github.com/users/"

  def start_link(),
    do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(args), do: {:ok, args}

  def fetch_user(username, cached_time \\ 360_000) do
    all_users = get_all_users()
    curr_user = User.find(all_users, username)
    do_fetch_user(curr_user, username, cached_time)
  end

  def get_all_users(), do: GenServer.call(__MODULE__, :get_all_users)

  def handle_call(:get_all_users, _from, users),
    do: {:reply, users, users}

  def handle_cast({:get_user, username}, users_cache) do
    user = get_user(username)
    {:noreply, [user | users_cache]}
  end

  def handle_cast({:update_user, username}, users_cache) do
    user = get_user(username)
    new_users_cache = User.update(users_cache, user)
    {:noreply, new_users_cache}
  end

  defp do_fetch_user(true, username) do
    GenServer.cast(__MODULE__, {:update_user, username})
  end

  defp do_fetch_user(false, username) do
    "User #{username} already cached."
  end

  defp do_fetch_user(nil, username, _cached_time) do
    GenServer.cast(__MODULE__, {:get_user, username})
  end

  defp do_fetch_user(user, username, cached_time) do
    is_cache_old = User.old_cache?(user, cached_time)
    do_fetch_user(is_cache_old, username)
  end

  defp get_user(username) do
    {:ok, response} = HTTPoison.get(@url <> username)
    {:ok, user} = Jason.decode(response.body)

    %User{
      username: username,
      avatar_url: user["avatar_url"],
      bio: user["bio"],
      created_at: user["created_at"],
      email: user["email"],
      id: user["id"],
      cached_at: DateTime.utc_now()
    }
  end
end
