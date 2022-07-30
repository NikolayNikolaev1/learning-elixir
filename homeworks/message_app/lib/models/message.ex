defmodule Models.Message do
  defstruct [
    :id,
    :from_user_id,
    :to_user_id,
    :text,
    :sent_at,
    :status,
    :is_edited
  ]

  def create(id, from_user_id, to_user_id, text) do
    %__MODULE__{
      id: id,
      from_user_id: from_user_id,
      to_user_id: to_user_id,
      text: text,
      sent_at: DateTime.utc_now(),
      status: :send,
      is_edited: false
    }
  end

  def find_by_id(messages, id) do
    message =
      Enum.filter(
        messages,
        fn msg -> msg.id === id end
      )

    do_find(message)
  end

  def read(messages, from_user_id) do
    Enum.map(messages, fn msg ->
      if msg.to_user_id === from_user_id and msg.status === :send do
        %{msg | status: :read}
      else
        msg
      end
    end)
  end

  def remove(messages, msg_id) do
    Enum.filter(messages, fn msg ->
      msg.id !== msg_id
    end)
  end

  def update(messages, [message_for_update]) do
    Enum.map(messages, fn msg ->
      if msg.id === message_for_update.id, do: message_for_update, else: msg
    end)
  end

  def update(messages, [current | messages_for_update]) do
    updated_messages =
      Enum.map(messages, fn msg ->
        if msg.id === current.id, do: current, else: msg
      end)

    update(updated_messages, messages_for_update)
  end

  defp do_find([]), do: nil

  defp do_find([message]), do: message
end
