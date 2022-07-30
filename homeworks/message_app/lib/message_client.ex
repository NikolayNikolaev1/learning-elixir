defmodule MessageClient do
  use GenServer
  alias Models.Message, as: Message

  def handle_call({:msg_all}, _from, messages), do: {:reply, messages, messages}

  def handle_call({:msg_delete, msg_id}, _from, messages) do
    message = Message.find_by_id(messages, msg_id)

    cond do
      message === nil ->
        {:reply, :id_not_found, messages}

      message.status === :read ->
        {:reply, :msg_read, messages}

      true ->
        {:reply, :success, Message.remove(messages, msg_id)}
    end
  end

  def handle_call({:msg_edit, msg_id, new_msg_text}, _from, messages) do
    message = Message.find_by_id(messages, msg_id)

    cond do
      message === nil ->
        {:reply, :id_not_found, messages}

      DateTime.diff(DateTime.utc_now(), message.sent_at) >= 60 ->
        {:reply, :timeout, messages}

      true ->
        updated_msg = %{message | text: new_msg_text}
        {:reply, :success, Message.update(messages, [updated_msg])}
    end
  end

  def handle_cast({:msg_read, from_user_id}, messages) do
    updated_messages = Message.read(messages, from_user_id)

    {:noreply, Message.update(messages, updated_messages)}
  end

  def handle_cast({:msg_send, from_user_id, to_user_id, text}, messages) do
    if messages === [] do
      new_message = Message.create(1, from_user_id, to_user_id, text)
      {:noreply, [new_message | messages]}
    else
      [last_msg | _] = messages
      new_message = Message.create(last_msg.id + 1, from_user_id, to_user_id, text)
      {:noreply, [new_message | messages]}
    end
  end

  def init(args), do: {:ok, args}
end
