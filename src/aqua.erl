-module(aqua).

-export([main/1, listener/0]).

listener() ->
  receive
    % {heartbeat}
    {data, Data} ->
      io:format("[Aquarium] Received data: ~p ~n", [Data]);
    {error, _Reason} ->
      io:format("[Aquarium] Error occured, shutting down.. ~n")

  end.

main(_) ->
  MainListener = spawn(aqua, listener, []),
  io:format("[Aquarium] starting ~p..~n", [MainListener]),
  TempController = spawn(temperature_controller, start, [MainListener]),
  io:format("[Aquarium] Started temperature controller ~p ~n", [TempController]),
  % temperature_probe:start(self()),
  Probe = spawn(temperature_probe, start, [MainListener]),
  io:format("[Aquarium] Started probe ~p ~n", [Probe]),
  % temperature_controller:start(self()),
  io:format("[Aquarium] Started all units~n"),
  receive
    {end, Reason} ->
      io:format("[Aquarium] end ~p ~n", [Reason])
  end.
