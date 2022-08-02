# MessageApp

**Description:
Create a messaging application that will hold the following functinality:

⚫ Creating of UserAccount - Register (username/email/password) a unique identifier should be created for each user, consider Discord approach of "#{username}##{four_digit_number}"
⚫ Logging into an Account - Login (after 3 consequitive wrong attempts to login, the login should be locked for 1 minute (for that username))
⚫ Each user should have a friendlist where he has access to all users that he has connected to.
- A connection between friends happens with sending an Invite for a friend request on one end and accepting the request on the other end.
- User A sends a friend request to User B -> then User B has the option to either accept or deny the request. 
If the request is denied, User A can send another request in order to optain friendship with User B and the potential to send messages to him
⚫ Sending a message to a User (messages can only be send if the user is in your friendlist and viceversa)
- A message can either have a status of "send" or "read";
- A message can be edited within 1 minute of the time of it being send, after that an edit should be impossible;
- A message can be deleted if the user on the other end has not read that message (basically reverting the send action). 
If the message has been read, the delete action should not be possible;

The messaging client should expose the following functions:
⚫ Sending a friend invite to a unique identifier (whatever you chose the unique identifier to be at step 1 above).
⚫ Lising all of your friend invitations that have been send to you.
⚫ Ability to accept/decline a particular friend invitation.
⚫ Ability to list all of your friends (your friendlist).
⚫ Ability to remove a user from your friendlist. (NB! This should remove all message history with that person as well).
⚫ Sending a message to someone in your friendlist.
⚫ Ability to delete/remove a send message if it's not yet read by your friend.
⚫ Ability to edit a message within 1 minute of being send (no matter if it was read or not) (NB! Edited messages should have some marker indicating that there was an edit)
⚫ Ability to list your chat with a friend of yours.
⚫ Ability to list all of your unread messages or with a specific friend.
⚫ List total amount of unread messages.**

## Commands Example

```elixir
MessageApp.start
user1 = MessageApp.register("test1", "test1", "test")
user2 = MessageApp.register("test2", "test2", "test")
user3 = MessageApp.register("test3", "test3", "test")
user4 = MessageApp.register("test4", "test4", "test")
user5 = MessageApp.register("test5", "test5", "test")
user6 = MessageApp.register("test6", "test6", "test")
user7 = MessageApp.register("test7", "test7", "test")
user8 = MessageApp.register("test8", "test8", "test")
user9 = MessageApp.register("test9", "test9", "test")
MessageApp.send_friend_request(user1.id, user2.id)
MessageApp.send_friend_request(user1.id, user3.id)
MessageApp.send_friend_request(user1.id, user4.id)
MessageApp.send_friend_request(user1.id, user5.id)
MessageApp.send_friend_request(user1.id, user6.id)
MessageApp.send_friend_request(user1.id, user7.id)
MessageApp.send_friend_request(user1.id, user8.id)
MessageApp.send_friend_request(user1.id, user9.id)
MessageApp.send_friend_request(user2.id, user4.id)
MessageApp.send_friend_request(user2.id, user6.id)
MessageApp.send_friend_request(user2.id, user8.id)
MessageApp.send_friend_request(user3.id, user5.id)
MessageApp.send_friend_request(user3.id, user7.id)
MessageApp.send_friend_request(user3.id, user9.id)
MessageApp.handle_friend_request(user5.id, user1.id, true)
MessageApp.handle_friend_request(user5.id, user3.id, true)
MessageApp.handle_friend_request(user6.id, user1.id, true)
MessageApp.handle_friend_request(user6.id, user2.id, true)
MessageApp.handle_friend_request(user2.id, user1.id, true)
MessageApp.handle_friend_request(user3.id, user1.id, true)
MessageApp.send_message(user1.id, user2.id, "Spam first msg")
MessageApp.send_message(user1.id, user2.id, "Spam second msg")
MessageApp.send_message(user1.id, user2.id, "Spam third msg")
MessageApp.send_message(user1.id, user3.id, "Spam first msg")
MessageApp.send_message(user1.id, user3.id, "Spam second msg")
MessageApp.send_message(user1.id, user3.id, "Spam third msg")
MessageApp.edit_message(user1.id, user2.id, 2, "Spam second msg --EDIT")
MessageApp.delete_message(user1.id, user3.id, 2)
MessageApp.edit_message(user1.id, user3.id, 3, "Spam third msg --EDIT")
MessageApp.send_message(user1.id, user3.id, "Spam fourth msg")
MessageApp.get_chat(user1.id, user2.id)
MessageApp.get_chat(user1.id, user3.id)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/message_app>.

