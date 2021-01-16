-module(light).

-export([start/1, process/1]).

turn_on() -> io:format("[Light] Turning on ~n").
turn_off() -> io:format("[Light] Turning off ~n").

process(Unit) ->
  receive
    {action, light, on} ->
      turn_on(),
      process(Unit);
    {action, light, off} ->
      turn_off(),
      process(Unit);
    E ->
      io:format("[Light] Unkown event: ~p ~n", [E]),
      process(Unit)
  end.

start(Unit) ->
  io:format("[Light] starting..~n"),
  spawn(light, process, [Unit]).