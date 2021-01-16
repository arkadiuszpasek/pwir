-module(temperature_probe).

-export([start/1, measure/1]).

measure(Unit) ->
  timer:sleep(5000),
  Payload = protocol:temperature_data(13),
  io:format("[Temperature probe] Sending measurement...~p to ~p ~n", [Payload, Unit]),
  Unit ! Payload,
  measure(Unit).

start(Unit) ->
  io:format("[Temperature probe] starting.. ~n"),

  measure(Unit).