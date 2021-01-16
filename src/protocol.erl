-module(protocol).

-export([temperature_data/1, heater_data/1]).

temperature_data(Data) -> {data, temperature, Data}.

heater_data(State) -> {data, heater, State}.
