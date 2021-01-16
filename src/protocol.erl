-module(protocol).

-export([temperature_data/1, heater_data/1]).
-export([light_off/0, light_on/0]).

temperature_data(Data) -> {data, temperature, Data}.

heater_data(State) -> {data, heater, State}.

light_on() -> {action, light, on}.
light_off() -> {action, light, off}.