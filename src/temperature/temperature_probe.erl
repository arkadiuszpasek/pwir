-module(temperature_probe).

-export([start/1, measure/1]).

measure(Main) ->
  timer:sleep(15000),
  Payload = protocol:temperature_data(rand:uniform(5) + 17),
  io:format("[Temperature probe] Sending measurement...~p to ~p ~n", [Payload, Main]),
  Main ! Payload,
  measure(Main).

start(Main) ->
  io:format("[Temperature probe] starting.. ~n"),

  spawn(temperature_probe, measure, [Main]).