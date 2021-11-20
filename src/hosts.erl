%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(hosts).   
 
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------


%% External exports
-export([
	 desired_state/0,
	 gap_desired_state/0
	]).



%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
desired_state()->
    Gap=[config_kublet:host_type(Host)||{Host,_Node}<-gap_desired_state()],
    io:format("Gap ~p~n",[Gap]),
    StartResult=start_kublets(Gap),
    io:format("Gap2 ~p~n",[gap_desired_state()]),
    
    StartResult.
   


%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
gap_desired_state()->
    DesiredHostsNodes=config_kublet:which_hosts_shall_be_contacted_to_create_cluster(),
    MissingHostNode=[{Host,Node}||{Host,Node}<-DesiredHostsNodes,
				  pong/=net_adm:ping(Node)],
    
    MissingHostNode. 
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

start_kublets(Gap)->
    start_kublets(Gap,[]).
start_kublets([],StartResult)->
    StartResult;
start_kublets([{Host,_Node,non_auto_erl_worker}|T],Acc) ->
    NewAcc=[start_kublet(Host)|Acc],
    start_kublets(T,NewAcc);
start_kublets([{Host,_Node,non_auto_erl_controller}|T],Acc) ->
    NewAcc=[start_kublet(Host)|Acc],
    start_kublets(T,NewAcc);
start_kublets([_|T],Acc)->
    start_kublets(T,Acc).
    


    

start_kublet(HostId)->
    ssh:start(),  
    Cookie=atom_to_list(erlang:get_cookie()),
    {Host,Ip,SshPort,UId,Pwd}=config_kublet:host_info(HostId),
    NodeName="kublet",
    Node=list_to_atom(NodeName++"@"++HostId),
    Result=case delete_vm(Node) of
	       {error,Reason}->
		   {error,Reason};
	       ok->
		   ErlCmd="erl_call -s "++"-sname "++NodeName++" "++"-c "++Cookie,
		   SshCmd="nohup "++ErlCmd++" &",
		   case rpc:call(node(),my_ssh,ssh_send,[Ip,SshPort,UId,Pwd,SshCmd,2*5000],3*5000) of
		       {badrpc,Reason}->
			  {error,[badrpc,Reason,Ip,SshPort,UId,Pwd,NodeName,Cookie,
				  ?FUNCTION_NAME,?MODULE,?LINE]};
		       {error,Reason}->
			   {error,[Reason,Ip,SshPort,UId,Pwd,NodeName,Cookie,
				   ?FUNCTION_NAME,?MODULE,?LINE]};
		       ErlcCmdResult->
			   io:format("ErlcCmdResult ~p~n",[{ErlcCmdResult,?MODULE,?FUNCTION_NAME,?LINE}]),
			   case node_started(Node) of
			       false->
				   {error,['failed to start', Ip,SshPort,UId,Pwd,NodeName,Cookie,ErlcCmdResult,
					   ?FUNCTION_NAME,?MODULE,?LINE]};
			       true->
				  {ok,Node}
			   end
		   end
	   end,
    Result.


delete_vm(Node)->
    rpc:call(Node,init,stop,[],5*1000),		   
    Result=case node_stopped(Node) of
	       false->
		   {error,["node not stopped",Node,?FUNCTION_NAME,?MODULE,?LINE]};
	       true->
		   ok
	   end,
    Result.

delete_vm(Node,Dir)->
    rpc:call(Node,os,cmd,["rm -rf "++Dir],5*1000),
    rpc:call(Node,init,stop,[],5*1000),		   
    Result=case node_stopped(Node) of
	       false->
		   {error,["node not stopped",Node,?FUNCTION_NAME,?MODULE,?LINE]};
	       true->

		   ok
	   end,
    Result.


%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
	      
node_started(Node)->
    check_started(100,Node,50,false).
    
check_started(_N,_Vm,_SleepTime,true)->
   true;
check_started(0,_Vm,_SleepTime,Result)->
    Result;
check_started(N,Vm,SleepTime,_Result)->
    io:format("net_Adm ~p~n",[{net_adm:ping(Vm),Vm}]),
    NewResult= case net_adm:ping(Vm) of
	%case rpc:call(node(),net_adm,ping,[Vm],1000) of
		  pong->
		     true;
		  pang->
		       timer:sleep(SleepTime),
		       false;
		   {badrpc,_}->
		       timer:sleep(SleepTime),
		       false
	      end,
    check_started(N-1,Vm,SleepTime,NewResult).

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

node_stopped(Node)->
    check_stopped(100,Node,50,false).
    
check_stopped(_N,_Vm,_SleepTime,true)->
   true;
check_stopped(0,_Vm,_SleepTime,Result)->
    Result;
check_stopped(N,Vm,SleepTime,_Result)->
 %   io:format("net_Adm ~p~n",[net_adm:ping(Vm)]),
    NewResult= case net_adm:ping(Vm) of
	%case rpc:call(node(),net_adm,ping,[Vm],1000) of
		  pang->
		     true;
		  pong->
		       timer:sleep(SleepTime),
		       false;
		   {badrpc,_}->
		       true
	       end,
    check_stopped(N-1,Vm,SleepTime,NewResult).

