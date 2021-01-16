-module(heater).

-export([start/2, process/2]).

internal_increase(State, Amount) ->
  #{power := Power} = State,
  NewPower = Power + Amount,

  io:format("[Heater: ~p] increasing power by ~p, current: ~p~n", [self(), Amount, NewPower]),
  maps:merge(State, #{power => NewPower}).

internal_decrease(State, Amount) ->
  #{power := Power} = State,
  NewPower = Power - Amount,

  if
    NewPower < 0 ->
      TurnedOffState = turn_off(State),
      maps:merge(TurnedOffState, #{power => 0});
    true ->
    io:format("[Heater: ~p] decreasing power by ~p, current: ~p~n", [self(), Amount, NewPower]),
    maps:merge(State, #{power => NewPower})
  end.

turn_off(State) ->
  io:format("[Heater: ~p] turned off ~n", [self()]),
  maps:merge(State, #{state => off}).

turn_on(State) ->
  io:format("[Heater: ~p] turned on ~n", [self()]),
  maps:merge(State, #{state => on}).

increase(State, Amount) -> 
  #{state := MyState} = State,
  if 
    MyState == off ->
      TurnedOnState = turn_on(State),
      internal_increase(TurnedOnState, Amount);
    true ->
      internal_increase(State, Amount)
    end.

decrease(State, Amount) -> 
  Updated = internal_decrease(State, Amount),
  #{power := Power} = Updated,

  if 
    Power < 0 ->
      turn_off(Updated);
    true ->
      Updated
    end.

process(Unit, State) ->
  receive
    {action, increase, Amount} ->
      Updated = increase(State, Amount),
      Unit ! protocol:heater_data(Updated),
      process(Unit, Updated);
    {action, decrease, Amount} ->
      Updated = decrease(State, Amount),
      Unit ! protocol:heater_data(Updated),
      process(Unit, Updated);
    {action, on} ->
      Updated = turn_on(State),
      Unit ! protocol:heater_data(Updated),
      process(Unit, Updated);
    {action, off} ->
      Updated = turn_off(State),
      Unit ! protocol:heater_data(Updated),
      process(Unit, Updated);
    E ->
      io:format("[Heater: ~p] Unkown event: ~p ~n", [self(), E]),
      process(Unit, State)
  end.

start(Unit, State) ->
  io:format("[Heater] starting.. ~n"),
  spawn(heater, process, [Unit, State]).