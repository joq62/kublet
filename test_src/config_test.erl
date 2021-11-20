%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  1
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(config_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("kernel/include/logger.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
  %  io:format("~p~n",[{"Start setup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=setup(),
  %  io:format("~p~n",[{"Stop setup",?MODULE,?FUNCTION_NAME,?LINE}]),

 %   io:format("~p~n",[{"Start host_info()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=host_info(),
    io:format("~p~n",[{"Stop host_info()",?MODULE,?FUNCTION_NAME,?LINE}]),

 %   io:format("~p~n",[{"Start host_type()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=host_type(),
    io:format("~p~n",[{"Stop host_type()",?MODULE,?FUNCTION_NAME,?LINE}]),

%   io:format("~p~n",[{"Start apps_to_start()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=apps_to_start(),
    io:format("~p~n",[{"Stop apps_to_start()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start which_nodes_shall_be_contacted_to_create_cluster()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=which_nodes_shall_be_contacted_to_create_cluster(),
    io:format("~p~n",[{"Stop which_nodes_shall_be_contacted_to_create_cluster()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start which_hosts_shall_be_contacted_to_create_cluster()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=which_hosts_shall_be_contacted_to_create_cluster(),
    io:format("~p~n",[{"Stop which_hosts_shall_be_contacted_to_create_cluster()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start which_nodes_shall_bully_contact()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=which_nodes_shall_bully_contact(),
    io:format("~p~n",[{"Stop which_nodes_shall_bully_contact()",?MODULE,?FUNCTION_NAME,?LINE}]),

 %   
      %% End application tests
  %  io:format("~p~n",[{"Start cleanup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=cleanup(),
  %  io:format("~p~n",[{"Stop cleaup",?MODULE,?FUNCTION_NAME,?LINE}]),
   
    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

which_nodes_shall_bully_contact()->
    [{"c200",kublet@c200},
     {"c201",kublet@c201}]=config_kublet:which_nodes_shall_bully_contact(),
    
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
which_nodes_shall_be_contacted_to_create_cluster()->
    [kublet@c100,
     kublet@c200,
     kublet@c201,
     kublet@c202,
     kublet@c203]=config_kublet:which_nodes_shall_be_contacted_to_create_cluster(),
    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
which_hosts_shall_be_contacted_to_create_cluster()->
    ["c200","c201","202","c203"]=config_kublet:which_hosts_shall_be_contacted_to_create_cluster(),
    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
apps_to_start()->
    [{bully,"1.0.0"},
     {sd,"1.0.0"},
     {controller,"1.0.0"}]=config_kublet:apps_to_start(auto_erl_controller),
     [{bully,"1.0.0"},
      {sd,"1.0.0"},
      {controller,"1.0.0"}]=config_kublet:apps_to_start(non_auto_erl_controller),
    [{sd,"1.0.0"}]=config_kublet:apps_to_start( non_auto_erl_worker),
    [{sd,"1.0.0"}]=config_kublet:apps_to_start( auto_erl_worker),
    undefined= config_kublet:apps_to_start(glurk),
    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

host_info()->
    {"c201","192.168.0.201",22,"joq62","festum01"}=config_kublet:host_info("c201"),
    "192.168.0.201"=config_kublet:host_info("c201",ip),
    22=config_kublet:host_info("c201",ssh_port),
    "joq62"=config_kublet:host_info("c201",uid),
    "festum01"=config_kublet:host_info("c201",passwd),
    undefined=config_kublet:host_info("c201",glurk),
    [{"c100","192.168.0.100",22,"joq62","festum01"},
     {"c200","192.168.0.200",22,"joq62","festum01"},
     {"c201","192.168.0.201",22,"joq62","festum01"},
     {"c202","192.168.0.202",22,"joq62","festum01"},
     {"c203","192.168.0.203",22,"pi","festum01"}]=config_kublet:host_info(),

    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

host_type()->
    {"c202",kublet@c202,auto_erl_worker}=config_kublet:host_type("c202"),
    {"c203",kublet@c203,non_auto_erl_worker}=config_kublet:host_type("c203"),

    [{"c100",kublet@c100},{"c203",kublet@c203}]=config_kublet:type(non_auto_erl_worker),
    [{"c202",kublet@c202}]=config_kublet:type(auto_erl_worker),
    [{"c200",kublet@c200},{"c201",kublet@c201}]=config_kublet:type(auto_erl_controller),

    [{"c100",kublet@c100,non_auto_erl_worker},
     {"c200",kublet@c200,auto_erl_controller},
     {"c201",kublet@c201,auto_erl_controller},
     {"c202",kublet@c202,auto_erl_worker},
     {"c203",kublet@c203,non_auto_erl_worker}]=config_kublet:host_type(),
    
    ok.



    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------


    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

   
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass1()->
   
    
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_2()->
    
     ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

setup()->
 %   {ok,I}=file:consult("boot.config"), 
   
    % create vm dirs
 %   NodesToStart=proplists:get_value(nodes_to_start,I),
   
 %   Dirs=[Dir||{_Host,Dir,Args}<-NodesToStart],
 %   Dirs=["1","2","3","4","5","6","7","8","9","controller","sd","dbase"],
 %   [os:cmd("rm -rf "++Dir)||Dir<-Dirs],   
   ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
  
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
