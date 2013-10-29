
-module (reliable_delivery_monitor_sup).

-behaviour(supervisor).

-export([start_link/0,start_monitor/2]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_monitor(Identifier, LeaseTime) ->
	supervisor:start_child(?MODULE,[Identifier,LeaseTime]).

init([]) ->
	Worker = { reliable_delivery_worker,{reliable_delivery_worker, start, []},
				temporary, brutal_kill, worker,[reliable_delivery_worker]},
	Children = [Worker],
	
	RestartStrategy = {simple_one_for_one, 0 ,1},
    {ok, { RestartStrategy, Children}}.
