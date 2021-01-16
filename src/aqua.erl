-module(aqua).

-export([main/1, manager/1]).

manager(Main) ->
  receive
    % {heartbeat}
    {error, Reason} ->
      io:format("[Aquarium] Error occured: ~p, shutting down.. ~n", [Reason]),
      manager(Main)

  end.

main(_) ->
  Manager = spawn(aqua, manager, [self()]),
  io:format("[Aquarium] started ~p..~n", [Manager]),

  TempController = spawn(temperature_controller, start, [Manager]),
  io:format("[Aquarium] Started temperature controller ~p ~n", [TempController]),

  io:format("[Aquarium] Started all units~n"),

  receive
    {finish, Reason} ->
      io:format("[Aquarium] end ~p ~n", [Reason])
  end.
