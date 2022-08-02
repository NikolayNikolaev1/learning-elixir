# Client side module of the UserAccounts and MessageClients GenServers.
defmodule MessageApp do
  alias Constants.ErrorMessage, as: ErrorMessage
  alias Constants.SuccessMessage, as: SuccessMessage

  def delete_message(user_id, to_user_id, msg_id) do
    response = GenServer.call(UserAccounts, {:get_mc_pid, user_id, to_user_id})

    case response do
      :friend_not_found ->
        ErrorMessage.friend_not_found(to_user_id)

      {:success, mc_pid} ->
        mc_response = GenServer.call(mc_pid, {:delete, user_id, msg_id})

        case mc_response do
          :msg_not_found ->
            ErrorMessage.message_not_found()

          :msg_read ->
            ErrorMessage.message_status_read()

          :success ->
            SuccessMessage.message_deleted()

          any ->
            ErrorMessage.any(any)
        end

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      any ->
        ErrorMessage.any(any)
    end
  end

  def edit_message(user_id, friend_id, msg_id, new_msg_text) do
    response = GenServer.call(UserAccounts, {:get_mc_pid, user_id, friend_id})

    case response do
      :friend_not_found ->
        ErrorMessage.friend_not_found(friend_id)

      {:success, mc_pid} ->
        mc_response = GenServer.call(mc_pid, {:edit, user_id, msg_id, new_msg_text})

        case mc_response do
          :msg_not_found ->
            ErrorMessage.message_not_found()

          :timeout ->
            ErrorMessage.message_edit_timeout()

          :success ->
            SuccessMessage.message_edited()

          any ->
            ErrorMessage.any(any)
        end

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      any ->
        ErrorMessage.any(any)
    end
  end

  def get_all_users(), do: GenServer.call(UserAccounts, :all)

  def get_chat(user_id, friend_id) do
    response = GenServer.call(UserAccounts, {:get_mc_pid, user_id, friend_id})

    case response do
      :friend_not_found ->
        ErrorMessage.friend_not_found(friend_id)

      {:success, mc_pid} ->
        GenServer.cast(mc_pid, {:read, user_id})
        GenServer.call(mc_pid, {:all})

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      any ->
        ErrorMessage.any(any)
    end
  end

  def get_friend_list(user_id) do
    response = GenServer.call(UserAccounts, {:friend_all, user_id})

    case response do
      [] ->
        "You do not have any friends at the moment."

      list ->
        list
    end
  end

  def get_friend_requests(user_id) do
    response = GenServer.call(UserAccounts, {:fr_all, user_id})

    case response do
      [] ->
        "You do not have any friend requests at the moment."

      list ->
        list
    end
  end

  def get_unread_messages(user_id) do
    response = GenServer.call(UserAccounts, {:get_all_mc_pids, user_id})

    case response do
      :no_friends ->
        ErrorMessage.friends_not_found()

      {:success, mc_pid_list} ->
        unread_messages =
          Enum.map(mc_pid_list, fn mc_pid ->
            msg = GenServer.call(mc_pid, {:get_unread, user_id})
            GenServer.cast(mc_pid, {:read, user_id})
            msg
          end)

        unread_messages

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      any ->
        ErrorMessage.any(any)
    end
  end

  def get_unread_messages(user_id, friend_id) do
    response = GenServer.call(UserAccounts, {:get_mc_pid, user_id, friend_id})

    case response do
      :friend_not_found ->
        ErrorMessage.friend_not_found(friend_id)

      {:success, mc_pid} ->
        unread_messages = GenServer.call(mc_pid, {:get_unread, user_id})
        GenServer.cast(mc_pid, {:read, user_id})
        unread_messages

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      any ->
        ErrorMessage.any(any)
    end
  end

  # List total amount of unread messages.
  def get_unread_messages_count(user_id) do
    response = GenServer.call(UserAccounts, {:get_all_mc_pids, user_id})

    case response do
      :no_friends ->
        ErrorMessage.friends_not_found()

      {:success, mc_pid_list} ->
        unread_messages =
          Enum.map(mc_pid_list, fn mc_pid ->
            GenServer.call(mc_pid, {:get_unread_msg_count, user_id})
          end)

        unread_msg_count = Enum.sum(unread_messages)
        SuccessMessage.unread_messages_count(unread_msg_count)

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      any ->
        ErrorMessage.any(any)
    end
  end

  # Accept friend request.
  def handle_friend_request(user_id, request_user_id, true) do
    {:ok, mc_pid} = GenServer.start_link(MessageClient, [])

    response = GenServer.call(UserAccounts, {:fr_accept, user_id, request_user_id, mc_pid})

    case response do
      :fr_not_found ->
        ErrorMessage.friend_request_not_found(request_user_id)

      :success ->
        SuccessMessage.friend_request_accepted(request_user_id)

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      any ->
        ErrorMessage.any(any)
    end
  end

  # Decline friend request.
  def handle_friend_request(user_id, request_user_id, false) do
    response = GenServer.call(UserAccounts, {:fr_decline, user_id, request_user_id})

    case response do
      :fr_not_found ->
        ErrorMessage.friend_request_not_found(request_user_id)

      :success ->
        SuccessMessage.friend_request_declined(request_user_id)

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      any ->
        ErrorMessage.any(any)
    end
  end

  def login(email, password) do
    response = GenServer.call(UserAccounts, {:login, email, password})

    case response do
      {:success, user} ->
        SuccessMessage.welcome(user.username)
        user

      {:timeout, timeout} ->
        ErrorMessage.login_timeout(email, timeout)

      :user_not_found ->
        ErrorMessage.email_not_found(email)

      nil ->
        ErrorMessage.incorect_credentials()

      any ->
        ErrorMessage.any(any)
    end
  end

  def register(username, email, password) do
    response = GenServer.call(UserAccounts, {:register, username, email, password})

    case response do
      :email_taken ->
        ErrorMessage.email_taken(email)

      {:success, user} ->
        SuccessMessage.welcome(user.username)
        user

      any ->
        ErrorMessage.any(any)
    end
  end

  def remove_friend(user_id, friend_id) do
    response = GenServer.call(UserAccounts, {:friend_remove, user_id, friend_id})

    case response do
      :equal_ids ->
        ErrorMessage.friend_request_to_self()

      :friend_not_found ->
        ErrorMessage.friend_not_found(friend_id)

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      :success ->
        SuccessMessage.friend_removed(friend_id)

      any ->
        ErrorMessage.any(any)
    end
  end

  def send_friend_request(from_user_id, to_user_id) do
    response = GenServer.call(UserAccounts, {:fr_send, from_user_id, to_user_id})

    case response do
      :equal_ids ->
        ErrorMessage.friend_request_to_self()

      :fr_exists ->
        ErrorMessage.friend_request_already_sent(to_user_id)

      :success ->
        SuccessMessage.friend_request_sent(to_user_id)

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      any ->
        ErrorMessage.any(any)
    end
  end

  def send_message(from_user_id, to_user_id, message) do
    response = GenServer.call(UserAccounts, {:get_mc_pid, from_user_id, to_user_id})

    case response do
      :friend_not_found ->
        ErrorMessage.friend_not_found(to_user_id)

      {:success, mc_pid} ->
        GenServer.cast(mc_pid, {:send, from_user_id, to_user_id, message})
        SuccessMessage.sent_message(to_user_id)

      {:user_not_found, id} ->
        ErrorMessage.user_id_not_found(id)

      any ->
        ErrorMessage.any(any)
    end
  end

  # Start application.
  def start(), do: UserAccounts.start_link()
end
