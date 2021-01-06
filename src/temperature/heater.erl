-module(heater).

-export([start/2, process/2]).

internal_increase(State, Amount) ->
  #{power := Power} = State,
  NewPower = Power + Amount,

  io:format("Heater ~p increasing power by ~p ~n", [self(), Amount]),
  io:format("Heater ~p current power: ~p ~n", [self(), NewPower]),
  maps:merge(State, #{power => NewPower}).

internal_decrease(State, Amount) ->
  #{power := Power} = State,
  NewPower = Power - Amount,

  if
    NewPower < 0 ->
      TurnedOffState = turn_off(State),
      maps:merge(TurnedOffState, #{power => 0});
    true ->
    io:format("Heater ~p decreasing power by ~p ~n", [self(), Amount]),
    io:format("Heater ~p current power: ~p ~n", [self(), NewPower]),
    maps:merge(State, #{power => NewPower})
  end.

turn_off(State) ->
  io:format("Heater ~p turned off ~n", [self()]),
  maps:merge(State, #{state => off}).

turn_on(State) ->
  io:format("Heater ~p turned on ~n", [self()]),
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
    {data, increase, Amount} ->
      Updated = increase(State, Amount),
      process(Unit, Updated);
    {data, decrease, Amount} ->
      Updated = decrease(State, Amount),
      process(Unit, Updated);
    {data, on} ->
      Updated = turn_on(State),
      process(Unit, Updated);
    {data, off} ->
      Updated = turn_off(State),
      process(Unit, Updated);
    _ ->
      io:format("Unkown event on heater: ~p ~n", [self()]),
      process(Unit, State)
  end.

start(Unit, State) ->
  spawn(heater, process, [Unit, State]).