%% This is the application resource file (.app file) for the 'base'
%% application.
{application, kublet,
[{description, "Boot service for raspberry boards" },
{vsn, "0.1.0" },
{modules, 
	  [kublet,kublet_sup,kublet_server]},
{registered,[kublet]},
{applications, [kernel,stdlib]},
{mod, {kublet_app,[]}},
{start_phases, []},
{git_path,"https://github.com/joq62/kublet.git"},
{env,[{service_catalog,[{dir,"service_catalog"},
	                {filename,"service.catalog"},
			{git_path,"https://github.com/joq62/service_catalog.git"}]}]}
]}.
