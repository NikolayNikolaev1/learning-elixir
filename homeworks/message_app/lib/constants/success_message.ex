defmodule Constants.SuccessMessage do
  def friend_request_accepted(from_user_id) do
    "Successfully accepted friend request from user with ID: #{from_user_id}!"
  end

  def friend_request_declined(from_user_id) do
    "Successfully declined friend request from user with ID: #{from_user_id}!"
  end

  def friend_request_sent(to_user_id) do
    "Friend request successfully sent to user with ID: #{to_user_id}!"
  end

  def friend_removed(user_id) do
    "User with ID: #{user_id} was successfully removed from your friend list!"
  end

  def message_edited(), do: "Message successfully edited!"

  def message_deleted(), do: "Message successfully deleted!"

  def sent_message(to_user_id) do
    "Successfully sent message to friend with ID: #{to_user_id}!"
  end

  def unread_messages_count(msg_count), do: "Total unread messages: #{msg_count}."

  def welcome(username), do: "Welcome, #{username}!"
end
