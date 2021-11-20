%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(config_kublet).   
 
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(KubletConfig,"kublet.config").

%% --------------------------------------------------------------------


%% External exports
-export([
	 apps_to_start/1,
	 nodes_to_contact/0,
%	 hosts_to_contact/0,
	 host_info/0,
	 host_info/1,
	 host_info/2,
	 host_type/0,
	 host_type/1,
	 type/1
	]).



%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
apps_to_start(Type)->
    {ok,I}=file:consult(?KubletConfig),
    Result=case Type of 
	       auto_erl_controller ->
		   proplists:get_value(auto_erl_controller_apps,I);
	       non_auto_erl_controller ->
		   proplists:get_value(non_auto_erl_controller_apps,I);
	       non_auto_erl_worker->
		   proplists:get_value(non_auto_erl_worker_apps,I);
	       auto_erl_worker->
		   proplists:get_value(auto_erl_worker_apps,I);
	       _->
		   undefined
	   end,
    Result.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
host_info()->
    {ok,I}=file:consult(?KubletConfig),
    proplists:get_value(host_info,I).
host_info(Host)->
    lists:keyfind(Host,1,host_info()).
host_info(Host,Type)->
    Result=case host_info(Host) of
	       undefined->
		   undefined;
	       {_,Ip,SshId,Uid,PassWd} ->
		   case Type of
		       ip->
			   Ip;
		       ssh_port->
			   SshId;
		       uid->
			   Uid;
		       passwd->
			   PassWd;
		       Type->
			   undefined
		   end
	   end,
    Result.
%% --------------------------------------------------------------------
%% Function:host_type(Host)->auto_erl_controller|non_auto_erl_controller
%%                               non_auto_erl_worker|non_auto_worker|
%%                               undefined
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
host_type()->
    {ok,I}=file:consult(?KubletConfig),
    proplists:get_value(host_type,I).
host_type(Host)->
    lists:keyfind(Host,1,host_type()).
type(XType)->
    [Host||{Host,Type}<-host_type(),
	   XType=:=Type].

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
nodes_to_contact()->
    {ok,I}=file:consult(?KubletConfig),   
    NodesToContact=proplists:get_value(nodes_to_contact,I),
    NodesToContact.

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
connect()->
    {ok,I}=file:consult(?KubletConfig),   
    NodesToConnect=proplists:get_value(nodes_to_contact,I),
    R=[{net_kernel:connect_node(Node),Node}||Node<-NodesToConnect],
    {ok,R}.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
clean_service_dir()->
    {ok,I}=file:consult(?KubletConfig),    
    ServiceDir=proplists:get_value(service_dir,I),
    os:cmd("rm -rf "++ServiceDir),
    ok=file:make_dir(ServiceDir),
    ok.

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
deallocate(Node,App)->
    stopped=rpc:call(Node,application,stop,[App],5*1000),
    slave:stop(Node),
    ok.



%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
allocate(App)-> % The calling shall monitor and take actions if node or application dies
    %% Start the needed Node 
    ServiceFile=atom_to_list(App)++".beam",
    ServiceFullFileName=code:where_is_file(ServiceFile),
    ServiceEbinDir=filename:dirname(ServiceFullFileName),
    Cookie=atom_to_list(erlang:get_cookie()),
    %% Infra functions needed [sd
    SdFileName=code:where_is_file("sd.beam"),
    SdEbinDir=filename:dirname(SdFileName),
    % start slave 
    Name =list_to_atom(lists:flatten(io_lib:format("~p",[erlang:system_time()]))),
    {ok,Host}=net:gethostname(),
    Args="-pa "++ServiceEbinDir++" "++"-pa "++SdEbinDir++" "++"-setcookie "++Cookie,
    {ok,Node}=slave:start(Host,Name,Args),
 %   io:format("Node nodes() ~p~n",[{Node,nodes()}]),
    true=net_kernel:connect_node(Node),
%    true=erlang:monitor_node(Node,true),
    %% Start application 
    ok=rpc:call(Node,application,start,[App],5*1000),
   
     %% Start the gen_server and monitor it instead of using superviosur  
%    {ok,PidApp}=rpc:call(Node,App,start,[],5000),
 %   AppMonitorRef=erlang:monitor(process,PidApp),
    {ok,Node}.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
load_services()->
    {ok,I}=file:consult(?KubletConfig),   
    ServiceCatalog=proplists:get_value(service_catalog,I),
    Dir=proplists:get_value(dir,ServiceCatalog),
    FileName=proplists:get_value(filename,ServiceCatalog),
    GitPath=proplists:get_value(git_path,ServiceCatalog),
    RootDir=proplists:get_value(service_dir,I),

    os:cmd("rm -rf "++RootDir),
    ok=file:make_dir(RootDir),
    os:cmd("rm -rf "++Dir),
    os:cmd("git clone "++GitPath),

    {ok,CatalogInfo}=catalog_info(Dir,FileName),
    [load_service(RootDir,ServiceInfo)||ServiceInfo<-CatalogInfo].
    

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
load_service(RootDir,{App,Vsn,GitPath})->
    AppId=atom_to_list(App),
    SourceDir=AppId,
    DestDir=filename:join(RootDir,AppId++"-"++Vsn),
    os:cmd("rm -rf "++DestDir),
    timer:sleep(1000),
    os:cmd("git clone "++GitPath),
    timer:sleep(1000),
    os:cmd("mv "++SourceDir++" "++DestDir),
    timer:sleep(1000),
    Result=case code:add_patha(filename:join(DestDir,"ebin")) of
	       true->
		   application:load(App),
		   {ok,App};
	       Reason->
		   {error,[Reason,App,DestDir]}
	   end,
    io:format(" ~p~n",[Result]),
    Result.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
catalog_info(Dir,FileName)->
    {ok,CatalogInfo}=file:consult(filename:join([Dir,FileName])),    
    {ok,CatalogInfo}.
