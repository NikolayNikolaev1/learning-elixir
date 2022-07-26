defmodule Constants.ErrorMessage do
  def email_not_found(email), do: "User with email #{email} does not exist."

  def email_taken(email), do: "User with email #{email} already exists."

  def friend_request_already_sent(id) do
    "Friend request already sent to user id: #{id}."
  end

  def incorect_credentials(), do: "Incorect credentials."

  def login_timeout(email, timeout) do
    "Login timeout for user email: #{email}. #{timeout} seconds left.."
  end

  def user_id_not_found(id), do: "User id #{id} does not exist."
end
