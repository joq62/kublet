%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(loader).   
 
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(KubletConfig,"kublet.config").

%% --------------------------------------------------------------------


%% External exports
-export([
	 clean_service_dir/0,
	 load_services/0,
	 load_services/2,
	 allocate/1,
	 deallocate/2
	]).



%% ====================================================================
%% External functions
%% ====================================================================

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

%% Debug support
load_services(Dir,FileName)->
    {ok,I}=file:consult(?KubletConfig),   
    ServiceCatalog=proplists:get_value(service_catalog,I),
    RootDir=proplists:get_value(service_dir,I),
    os:cmd("rm -rf "++RootDir),
    ok=file:make_dir(RootDir),
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
