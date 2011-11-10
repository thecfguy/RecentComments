<cfcomponent extends="org.mangoblog.plugins.BasePlugin">

	<cfset variables.package = "com/thecfguy/mango/plugins/recentcomments"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
						
			<cfset super.init(arguments.mainManager, arguments.preferences) />
			<cfset variables.manager = arguments.mainManager />
			<cfset initSettings(commentperpage=10) />
			
		<cfreturn this/>
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfset super.setup() />
		<cfreturn "recentcomments plugin activated. <br />You will find additional link admin navigation" />
	</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		<cfset var local = structnew() />
		<cfset var blog = request.blogManager.getBlog() />
		<cfif  arguments.event.name is "mainNav">
			<cfset local.link = structnew() />
			<cfset local.link.owner = "recentcomments">
			<cfset local.link.page = "generic" />
			<cfset local.link.title = "Comments" />
			<cfset local.link.eventName = "showrecentcomments" />
			<cfset link.icon = "#blog.Url#assets/plugins/recentcomments/comments.png" />
			<cfset arguments.event.addLink(local.link)>
			
		<cfelseif arguments.event.name EQ "showrecentcomments">
			<cfset data = arguments.event.getData() />
			<cfset local.blog = variables.manager.getBlog() />
			
			<cfif variables.manager.isCurrentUserLoggedIn() 
					AND listfind(variables.manager.getCurrentUser().getCurrentRole(local.blog.getId()).permissions, "manage_comments")>
				<cfset local.allowEdit = true>
			</cfif>	
			<cfsavecontent variable="page">
				<cfinclude template="admin/manager.cfm">
			</cfsavecontent>
			
			<!--- change message --->
			<cfset data.message.setTitle("Comments") />
			<cfset data.message.setData(page) />
		</cfif>
		<cfreturn arguments.event />
		
	</cffunction>

</cfcomponent>