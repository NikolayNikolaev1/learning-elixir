defmodule Constants.ErrorMessage do
  def any(any), do: "Any: #{any}"

  def email_not_found(email), do: "User with email #{email} does not exist."

  def email_taken(email), do: "User with email #{email} already exists."

  def friends_not_found(), do: "You do not have any friends at the moment."

  def friend_not_found(id) do
    "User with ID: #{id} does not exist in your friend list."
  end

  def friend_request_already_sent(id) do
    "Friend request already sent to user id: #{id}."
  end

  def friend_request_not_found(id) do
    "Friend request from user with ID: #{id} does not exist."
  end

  def friend_request_to_self() do
    "Cannot send freidn request to self."
  end

  def incorect_credentials(), do: "Incorect credentials."

  def login_timeout(email, timeout) do
    "Login timeout for user email: #{email}. #{timeout} seconds left.."
  end

  def message_edit_timeout() do
    "A message can be edited within 1 minute of the time of it being send, after that an edit is impossible."
  end

  def message_not_found(), do: "Message does not exist."

  def message_status_read(), do: "Cannot delete message with status: read."

  def user_not_found(), do: "User does not exist."

  def user_id_not_found(id), do: "User with ID: #{id} does not exist."
end
