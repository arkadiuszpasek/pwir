-module(protocol).

-export([create_data_payload/1, create_action_payload/2]).

create_data_payload(Data) -> 
  {data, Data}.

create_action_payload(Type, Action) ->
  {action, Type, Action}.