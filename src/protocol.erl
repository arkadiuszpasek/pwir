-module(protocol).

-export([temperature_data/1]).

temperature_data(Data) -> {data, temperature, Data}.
