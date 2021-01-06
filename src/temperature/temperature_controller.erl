-module(temperature_controller).

-export([start/1, unit/3]).

unit(Server, State, Heater) ->
  receive
    {action, increase, Amount} ->
      Heater ! {action, increase, Amount},
      unit(Server, State, Heater);
    {action, decrease, Amount} ->
      Heater ! {action, decrease, Amount},
      unit(Server, State, Heater);
    {action, on} ->
      Heater ! {action, on},
      unit(Server, State, Heater);
    {action, off} ->
      Heater ! {action, off},
      unit(Server, State, Heater)
  end.


start(Server) ->
  InitialState = #{
    heater => #{
      state => off,
      power => 0  
    }
  },

  Heater = heater:start(self(), maps:get(heater, InitialState)),
  spawn(temperature_controller, unit, [Server, InitialState, Heater]).