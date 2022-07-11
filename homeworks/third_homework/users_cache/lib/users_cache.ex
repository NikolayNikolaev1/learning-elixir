defmodule UsersCache do
  use GenServer
  alias Models.User, as: User
  @url "https://api.github.com/users/"

  def start_link(),
    do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def all(), do: GenServer.call(__MODULE__, :all)

  def fetch(username) do
    users = all()
    fetch(User.contains(users, username), username)
  end

  defp fetch(true, username),
    do: "User #{username} already cached."

  defp fetch(false, username),
    do: GenServer.cast(__MODULE__, {:fetch, username})

  def init(args), do: {:ok, args}

  def handle_call(:all, _from, users),
    do: {:reply, users, users}

  def handle_cast({:fetch, username}, users_cache) do
    {:ok, response} = HTTPoison.get(@url <> username)
    {:ok, user} = Jason.decode(response.body)

    new_user = %User{
      username: username,
      avatar_url: user["avatar_url"],
      bio: user["bio"],
      created_at: user["created_at"],
      email: user["email"],
      id: user["id"]
    }

    {:noreply, [new_user | users_cache]}
  end
end
