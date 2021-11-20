%%% -------------------------------------------------------------------
%%% Author  : joqerlang
%%% Description : compute
%%% 
%%% Created : 
%%% -------------------------------------------------------------------
-module(kublet_server).

-behaviour(gen_server).  

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
% -include("").
-include_lib("kernel/include/logger.hrl").
%% --------------------------------------------------------------------
%% External exports
 

%% gen_server callbacks



-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================





%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    LoadedServices=rpc:call(node(),loader,load_services,[]),
    io:format("LoadedServices ~p~n",[LoadedServices]),
    NodesToContact=rpc:call(node(),loader,nodes_to_contact,[]),
    io:format("NodesToContact ~p~n",[NodesToContact]),
    
    
    ok=application:set_env([{bully,[{nodes,NodesToContact}]}]),
    ok=application:start(bully),
    ok=application:start(sd),
    ok=application:start(controller),

    

    
    
    
    
    
    
 %   case application:get_env(mode) of
%	{mode,worker}->	
%	    ok;
%	{mode,controller}->
%	    {ok,_ControllerNode}=loader:allocate(controller)
 %   end,
   % {ok,ControllerNode}=loader:allocate(controller)
    ?LOG_NOTICE(#{module=>?MODULE,function=>?FUNCTION_NAME,line=>?LINE,
		  msg=>"server started/restarted\n"}),
    
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({}, _From, State) ->
    Reply = boot_loader:get_nodes(),
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------


handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{Msg,?MODULE,?LINE,time()}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Exported functions
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
