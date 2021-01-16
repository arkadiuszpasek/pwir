-module(panel).

-export([start/1, panel/1]).

turn_on_light_pressed(Server) ->
  Server ! protocol:light_on().

panel(Server) ->
  % listen for user interacting with panel

  % simulate action
  timer:sleep(5000),
  turn_on_light_pressed(Server).

start(Server) ->
  io:format("[Control Panel] starting.. ~n"),

  spawn(panel, panel, [Server]).