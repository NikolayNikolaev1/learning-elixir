defmodule MessageApp do
  alias Constants.ErrorMessage, as: ErrorMessage

  def get_all_users(), do: GenServer.call(UserAccounts, :all)

  def get_chat(user_id, friend_id) do
    response = GenServer.call(UserAccounts, {:get_mc_pid, user_id, friend_id})

    case response do
      :friend_not_found ->
        "Not friends"

      mc_pid ->
        GenServer.cast(mc_pid, {:msg_read, user_id})
        GenServer.call(mc_pid, {:msg_all})
    end
  end

  def get_friend_list(user_id) do
    GenServer.call(UserAccounts, {:friend_all, user_id})
  end

  def get_friend_requests(user_id) do
    GenServer.call(UserAccounts, {:fr_all, user_id})
  end

  def handle_friend_request(user_id, request_user_id, true) do
    {:ok, mc_pid} = GenServer.start_link(MessageClient, [])

    GenServer.cast(UserAccounts, {:fr_accept, user_id, request_user_id, mc_pid})
  end

  def handle_friend_request(user_id, request_user_id, false) do
    GenServer.cast(UserAccounts, {:fr_decline, user_id, request_user_id})
  end

  def message_delete(user_id, to_user_id, msg_id) do
    response = GenServer.call(UserAccounts, {:get_mc_pid, user_id, to_user_id})

    case response do
      :friend_not_found ->
        "Not friends"

      mc_pid ->
        mc_response = GenServer.call(mc_pid, {:msg_delete, msg_id})

        case mc_response do
          :id_not_found ->
            "Message id not found"

          :msg_read ->
            "Message with status read cannot be deleted"

          :success ->
            "Message successfully deleted"
        end
    end
  end

  def message_edit(user_id, to_user_id, msg_id, new_msg_text) do
    response = GenServer.call(UserAccounts, {:get_mc_pid, user_id, to_user_id})

    case response do
      :friend_not_found ->
        "Not friends"

      mc_pid ->
        mc_response = GenServer.cast(mc_pid, {:msg_edit, msg_id, new_msg_text})

        case mc_response do
          :id_not_found ->
            "Message with id not found"

          :timeout ->
            "Messages can be edited only 1min after being sent"

          :success ->
            "Message successfully edited"
        end
    end
  end

  def message_send(from_user_id, to_user_id, message) do
    response = GenServer.call(UserAccounts, {:get_mc_pid, from_user_id, to_user_id})

    case response do
      :friend_not_found ->
        "Not friends"

      mc_pid ->
        GenServer.cast(mc_pid, {:msg_send, from_user_id, to_user_id, message})
    end
  end

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
    response = GenServer.call(UserAccounts, {:register, username, email, password})

    case response do
      :email_taken ->
        ErrorMessage.email_taken(email)

      user ->
        "Welcome, #{user.username}!"
        user
    end
  end

  def remove_friend(user_id, friend_id) do
    response = GenServer.call(UserAccounts, {:friend_remove, user_id, friend_id})

    case response do
      :incorect_friend_id ->
        "#{friend_id} invorect id"

      :success ->
        "friend removed"
    end
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

  def start(), do: UserAccounts.start_link()
end
