# Module for handling diffrent message client GenServers for user that are friends.
defmodule MessageClient do
  use GenServer
  alias Models.Message, as: Message

  def handle_call({:all}, _from, messages), do: {:reply, messages, messages}

  # Remove message from state.
  def handle_call({:delete, user_id, msg_id}, _from, messages) do
    message = Message.find_by_id(messages, msg_id)

    cond do
      message === nil ->
        {:reply, :msg_not_found, messages}

      message.from_user_id !== user_id ->
        {:reply, :not_autorized, messages}

      # If the message has status: read, the delete action is not possible.
      message.status === :read ->
        {:reply, :msg_read, messages}

      true ->
        {:reply, :success, Message.remove(messages, msg_id)}
    end
  end

  # Edit message in state.
  def handle_call({:edit, user_id, msg_id, new_msg_text}, _from, messages) do
    message = Message.find_by_id(messages, msg_id)

    cond do
      message === nil ->
        {:reply, :msg_not_found, messages}

      message.from_user_id !== user_id ->
        {:reply, :not_autorized, messages}

      # Message can be edited within 1 minute of the time of it being send.
      DateTime.diff(DateTime.utc_now(), message.sent_at) >= 60 ->
        {:reply, :timeout, messages}

      true ->
        updated_msg = %{message | text: new_msg_text, is_edited: true}
        {:reply, :success, Message.update(messages, [updated_msg])}
    end
  end

  # Set all message status to read.
  def handle_cast({:read, from_user_id}, messages) do
    updated_messages = Message.read(messages, from_user_id)

    {:noreply, Message.update(messages, updated_messages)}
  end

  # Create new message and add it to the state.
  def handle_cast({:send, from_user_id, to_user_id, text}, messages) do
    if messages === [] do
      # Create new message with id: 1 if there are no other messages in the state.
      new_message = Message.create(1, from_user_id, to_user_id, text)
      {:noreply, [new_message | messages]}
    else
      # Take the last message id to create next message.
      [last_msg | _] = messages
      new_message = Message.create(last_msg.id + 1, from_user_id, to_user_id, text)
      {:noreply, [new_message | messages]}
    end
  end

  def init(args), do: {:ok, args}
end
