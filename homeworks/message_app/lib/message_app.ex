defmodule MessageApp do
  use GenServer
  alias Constants.ErrorMessage, as: ErrorMessage
  alias UserAccount

  def init(args), do: {:ok, args}

  def get_friend_list(user_id) do
    GenServer.call(UserAccounts, {:fl_all, user_id})
  end

  def get_friend_requests(user_id) do
    GenServer.call(UserAccounts, {:fr_all, user_id})
  end

  def send_friend_request(from_user_id, to_user_id) do
    response = GenServer.call(UserAccounts, {:fr_send, from_user_id, to_user_id})

    case response do
      :user_id_not_found ->
        ErrorMessage.user_id_not_found(to_user_id)

      :fr_to_self ->
        "To self"

      :fr_exists ->
        ErrorMessage.friend_request_already_sent(to_user_id)

      :success ->
        "Success!"
    end
  end

  def start_link(user),
    do: GenServer.start_link(__MODULE__, {user.id, user.username, user.email, [], []})
end
