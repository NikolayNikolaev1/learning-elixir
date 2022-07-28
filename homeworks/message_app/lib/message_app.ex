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

  def handle_friend_request(user_id, request_user_id, true) do
    GenServer.cast(UserAccounts, {:fr_accept, user_id, request_user_id})

    {:ok, pid} = GenServer.start_link(__MODULE__, {user_id, request_user_id, []})
    pid
  end

  def handle_friend_request(user_id, request_user_id, false) do
    GenServer.cast(UserAccounts, {:fr_decline, user_id, request_user_id})
  end
end
