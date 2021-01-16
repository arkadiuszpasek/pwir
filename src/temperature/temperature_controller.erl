-module(temperature_controller).

-export([start/1, unit/2, unit/4]).

process_temperature(Temperature, Heater) when Temperature > 21 ->
  Heater ! {action, decrease, 100};
process_temperature(Temperature, Heater) when Temperature < 19 ->
  Heater ! {action, increase, 100};
process_temperature(_, _) -> ok.

process_heater_data(HeaterState, State) ->
  State#{heater := HeaterState}.

unit(Server, State) ->
  Probe = spawn(temperature_probe, start, [self()]),
  io:format("[Temperature controller] Started probe ~p ~n", [Probe]),

  Heater = heater:start(self(), maps:get(heater, State)),
  io:format("[Temperature controller] Started heater ~p ~n", [Heater]),

  unit(Server, State, Heater, Probe).

unit(Server, State, Heater, Probe) ->
  io:format("[Temperature controller] Current state: ~p ~n", [State]),
  receive
    {action, increase, Amount} ->
      Heater ! {action, increase, Amount},
      unit(Server, State, Heater, Probe);
    {action, decrease, Amount} ->
      Heater ! {action, decrease, Amount},
      unit(Server, State, Heater, Probe);
    {action, on} ->
      Heater ! {action, on},
      unit(Server, State, Heater, Probe);
    {action, off} ->
      Heater ! {action, off},
      unit(Server, State, Heater, Probe);
    {data, heater, Data} ->
      io:format("[Temperature controller] Received heater state: ~p ~n", [Data]),
      UpdatedState = process_heater_data(Data, State),
      unit(Server, UpdatedState, Heater, Probe);
    {data, temperature, Temperature} ->
      io:format("[Temperature controller] Received temperature measure: ~p ~n", [Temperature]),
      process_temperature(Temperature, Heater),
      unit(Server, State, Heater, Probe);
    {error, Reason} ->
      Server ! {error, Reason};
    E ->
      io:format("[Temperature controller] Unkown event: ~p ~n", [E])
  end.

start(Server) ->
  InitialState = #{
    heater => #{
      state => off,
      power => 0  
    }
  },

  Unit = spawn(temperature_controller, unit, [Server, InitialState]),
  io:format("[Temperature controller] starting.. ~p~n", [Unit]).
