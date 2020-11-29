# TODO

- Implemented a game loop in a elixir process that send back the board by ways of a socket. Need to implement a different solution so that the result of the move is calculated on the back end and just the reult is sent to the server


To read:
- Implement a dispatch method on the Registry and register data under one key. Once you call dispatch on that key you can use a callback and receive all the data behind the key -> read more: https://hexdocs.pm/elixir/master/Registry.html#module-using-as-a-dispatcher