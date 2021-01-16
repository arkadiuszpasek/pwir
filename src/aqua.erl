-module(aqua).

-export([main/1, manager/1, manager/4]).

manager(Main) ->
  TempController = spawn(temperature_controller, start, [self()]),
  io:format("[Aquarium] Started Temperature controller ~p ~n", [self()]),

  Panel = panel:start(self()),
  io:format("[Aquarium] Started Control panel ~p ~n", [Panel]),

  Light = light:start(self()),
  io:format("[Aquarium] Started Light unit ~p ~n", [Light]),

  io:format("[Aquarium] Started all units~n"),
  manager(Main, TempController, Light, Panel).

manager(Main, TempController, Light, Panel) ->
  receive
    {action, light, on} ->
      Light ! protocol:light_on(),
      manager(Main, TempController, Light, Panel);
    {error, Reason} ->
      io:format("[Aquarium] Error occured: ~p, shutting down.. ~n", [Reason]),
      manager(Main, TempController, Light, Panel);
    E ->
      io:format("[Aquarium] Unkown event: ~p ~n", [E]),
      manager(Main, TempController, Light, Panel)
  end.

main(_) ->
  Manager = spawn(aqua, manager, [self()]),
  io:format("[Aquarium] started ~p..~n", [Manager]),

  receive
    {finish, Reason} ->
      io:format("[Aquarium] end ~p ~n", [Reason])
  end.
