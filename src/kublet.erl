%% Author: joqerlang
%% Created: 2021-11-18 
%% Connect/keep connections to other nodes
%% clean up of computer (removes all applications but keeps log file
%% git loads or remove an application ,loadand start application
%%  
%% Starts either as controller or worker node, given in application env 
%% Controller:
%%   git clone and starts 
%%
%% Description: TODO: Add description to application_org
%%
-module(kublet).
 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("kernel/include/logger.hrl").
%% --------------------------------------------------------------------
%% Behavioural exports
%% --------------------------------------------------------------------
-export([
	 

	 available_hosts/0,
	 start_app/1,
	 get_nodes/0
        ]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 boot/0,
	 start/0,
	 stop/0
	]).
%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------
boot()->
    application:start(?MODULE).

%% ====================================================================!
%% External functions
%% ====================================================================!
%% --------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}
%% --------------------------------------------------------------------
-define(SERVER,kublet_server).

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).
   
get_nodes()->
    gen_server:call(?SERVER, {get_nodes},infinity).
available_hosts()->
    gen_server:call(?SERVER, {available_hosts},infinity).
start_app(App)->
    gen_server:call(?SERVER, {start_app,App},infinity).

