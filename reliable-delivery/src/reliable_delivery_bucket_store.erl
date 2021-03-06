-module (reliable_delivery_bucket_store).

-behaviour(gen_server).

-export ([start_link/0, push/4, pop/1, ack/1, get_state/1, expire_monitor/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include ("reliable_delivery.hrl").

push(Identifier, LeaseTime, Application, Value) ->
  gen_server:call(?MODULE, {push, Identifier, LeaseTime, Application, Value }).

pop(Bucket) ->
  gen_server:call(?MODULE, {pop, Bucket}).

ack(Identifier) ->
  gen_server:call(?MODULE, {ack, Identifier}).

get_state(Identifier) ->
  gen_server:call(?MODULE, {get_state, Identifier}).

expire_monitor(Identifier) ->
  gen_server:call(?MODULE, {expire_monitor, Identifier}).

start_link() ->
  gen_server:start({local, ?MODULE}, ?MODULE, [], []).

init(_) ->
  	{ok, []}.


handle_call({expire_monitor, Identifier},_, State) ->

  Reply = reliable_delivery_bucket_store_lite:update_expired_monitor(Identifier),
  {reply, Reply, State};
handle_call({push, Identifier, LeaseTime, Application, Value },_, State) ->
  
  { bucket, Bucket, OffsetInBucket } = reliable_delivery_bucket_manager:get_bucket(LeaseTime),

  reliable_delivery_bucket_store_lite:push_to_bucket( Bucket, OffsetInBucket, Identifier, LeaseTime, Application, Value),
  reliable_delivery_monitor_stats:increment_persisted_monitors(),

  {reply, ok, State};
handle_call({pop, Bucket },_, State) ->

  Reply = reliable_delivery_bucket_store_lite:pop_from_bucket(Bucket),
  
  {reply, Reply, State};
handle_call({ack, Identifier},_, State) ->

  Reply = reliable_delivery_bucket_store_lite:ack_with_identifier(Identifier),

  {reply, Reply , State};
handle_call({get_state, Identifier},_, State) ->

  Reply = reliable_delivery_bucket_store_lite:get_state_for_monitor(Identifier),
  {reply, Reply, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
