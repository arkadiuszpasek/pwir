-module(aqua).

-export([main/1]).

main(_) -> 
  io:format("Hello"),
  temperature_controller:start(self()).