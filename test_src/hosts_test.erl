%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  1
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(hosts_test).   
    
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

 %   io:format("~p~n",[{"Start ssh_test()",?MODULE,?FUNCTION_NAME,?LINE}]),
 %   ok=ssh_test(),
 %   io:format("~p~n",[{"Stop ssh_test()",?MODULE,?FUNCTION_NAME,?LINE}]),
 %   io:format("~p~n",[{"Start gap_desired_state()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=gap_desired_state(),
    io:format("~p~n",[{"Stop gap_desired_state()",?MODULE,?FUNCTION_NAME,?LINE}]),


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
ssh_test()->
    Ip="192.168.0.203",
    SshPort=22,UId="pi",Pwd="festum01",
    NodeName="kublet",
        ssh:start(),  
    Cookie=atom_to_list(erlang:get_cookie()),

 %   ErlCmd="erl_call -s "++"-sname "++NodeName++" "++"-c "++Cookie,
    ErlCmd="/snap/erlang/current/usr/bin/erl -sname "++NodeName++" "++"-setcookie "++Cookie++" -detached",
    SshCmd="nohup "++ErlCmd++" &",
		 %  SshCmd="date",
    Result=rpc:call(node(),my_ssh,ssh_send,[Ip,SshPort,UId,Pwd,SshCmd,2*5000],3*5000),
     io:format("Result ~p~n",[{Result,?MODULE,?FUNCTION_NAME,?LINE}]),
   
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
gap_desired_state()->
    rpc:cast(kublet@c203,init,stop,[]),
    timer:sleep(2000),
    io:format("nodes() ~p~n",[{nodes(),?MODULE,?FUNCTION_NAME,?LINE}]),
   
    [{ok,kublet@c203}]=hosts:desired_state(),
     io:format("nodes() ~p~n",[{nodes(),?MODULE,?FUNCTION_NAME,?LINE}]), 
    
    ResL=[{Node,rpc:call(Node,application,which_applications,[],5*1000)}||Node<-nodes()],
    io:format("ResL~p~n",[{ResL,?MODULE,?FUNCTION_NAME,?LINE}]), 

    

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
