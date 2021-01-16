-module(temperature_probe).

-export([start/1, measure/1]).

measure(Main) ->
  % timer:sleep(10000),
  timer:sleep(4000),
  % Payload = protocol:temperature_data(rand:uniform(5) + 17),
  Payload = protocol:temperature_data(15),
  io:format("[Temperature probe] Sending measurement...~p to ~p ~n", [Payload, Main]),
  Main ! Payload,
  measure(Main).

start(Main) ->
  io:format("[Temperature probe] starting.. ~n"),

  measure(Main).