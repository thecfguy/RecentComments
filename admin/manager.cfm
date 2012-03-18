<cfoutput>
<cfsilent>
	<cfparam name="form.primaryAction" default="">
	<cfparam name="form.editMode" default="false">
	<cfparam name="form.page" default="1">
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlogId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset message ="">
	<cfset msgClass="">
	<cfif listfind(currentRole.permissions, "manage_comments")>
		<cfswitch expression="#form.primaryAction#">
			<cfcase value="edit">
				<cfset form.editMode = true>
				<cftry>
					<cfset comment = request.administrator.getComment(form.id) />
					<cfset content = comment.getContent() />
					<cfset email = comment.getCreatorEmail() />
					<cfset name = comment.getCreatorName() />
					<cfset website = comment.getCreatorUrl() />
					<cfset approved = comment.getApproved() />
					<cfset createdOn = dateformat(comment.getCreatedOn(),'short') & " " & timeformat(comment.getCreatedOn(),'medium') />
				<cfcatch type="any">
					<cfset error = cfcatch.message />
				</cfcatch>
				</cftry>
			</cfcase>
			<cfcase value="approve">
				<cfset comment = request.administrator.getComment(form.id) />
				<cfset form.commentId = form.id />
				<cfset form.content = comment.getContent() />
				<cfset form.creatorEmail = comment.getCreatorEmail() />
				<cfset form.creatorName = comment.getCreatorName() />
				<cfset form.creatorUrl = comment.getCreatorUrl() />
				<cfset form.approved = true />
				<cfset result = request.formHandler.handleEditComment(form) />
				<cfif result.message.getStatus() eq "success">
					<cfset msgClass = "message">
				<cfelse>
					<cfset msgClass = result.message.getStatus()>
				</cfif>
				<cfset message = result.message.getText() />
			</cfcase>
			<cfcase value="save">
				<cfset result = request.formHandler.handleEditComment(form) />
				<cfif result.message.getStatus() eq "success">
					<cfset msgClass = "message">
				<cfelse>
					<cfset msgClass = result.message.getStatus()>
				</cfif>
				<cfset message = result.message.getText() />
			</cfcase>
			<cfcase value="delete">
				<cfset result = request.formHandler.handleDeleteComment(form) />
				<cfif result.message.getStatus() eq "success">
					<cfset msgClass = "message">
				<cfelse>
					<cfset msgClass = result.message.getStatus()>
				</cfif>
				<cfset message = result.message.getText() />
			</cfcase>
		</cfswitch>
	</cfif>
	<cfset totalComment = variables.manager.getCommentsManager().getCommentCount(true)>
	<cfset totalpage = Ceiling(totalComment/variables.settings.commentperpage)>
	<cfset startIndex = (form.page-1)*variables.settings.commentperpage + 1>
	<cfset recentComments = variables.manager.getCommentsManager().getRecentComments(form.page*variables.settings.commentperpage,true)>
</cfsilent>
<script type="text/javascript">
	function deleteComment(id){
		document.frmcomment.primaryAction.value = "delete";
		document.frmcomment.id.value = id;
		document.frmcomment.submit();
	}
	function editComment(id){
		document.frmcomment.primaryAction.value = "edit";
		document.frmcomment.id.value = id;
		document.frmcomment.submit();
	}
	function saveComment(id){
		document.frmcomment.primaryAction.value = "save";
		document.frmcomment.id.value = id;
		document.frmcomment.submit();
	}
	function approveComment(id){
		document.frmcomment.primaryAction.value = "approve";
		document.frmcomment.id.value = id;
		document.frmcomment.submit();
	}
	function moveTo(newpage){
		document.frmcomment.page.value = newpage;
		document.frmcomment.submit();
	}
</script>

<form method="post" action="#cgi.script_name#" name="frmcomment">
	<cfif len(message)>
		<p class="#msgclass#"><cfoutput>#message#</cfoutput></p>
	</cfif>
	<cfif form.editMode>
		<p>
			<label for="creatorName">Name</label>
			<span class="field"><input type="text" id="creatorName" name="creatorName" value="#htmleditformat(name)#" size="40" class="required"/></span>
		</p>
		
		<p>
			<label for="creatorEmail">Email</label>
			<span class="field"><input type="text" id="creatorEmail" name="creatorEmail" value="#htmleditformat(email)#" size="40" class="required email"/></span>
		</p>
		
		<p>
			<label for="creatorUrl">Website</label>
			<span class="field"><input type="text" id="creatorUrl" name="creatorUrl" value="#htmleditformat(website)#" size="40" class="url"/></span>
		</p>
		
		<p>
			<label for="content">Comment</label>
			<span class="field">
				<textarea cols="80" rows="10" id="content" name="content" class="required">#htmleditformat(content)#</textarea></span>
		</p>

		<p>
			<input type="checkbox" id="approved" name="approved" value="yes" <cfif approved>checked="checked"</cfif>/><label for="approved">Approved?</label>
		</p>
			
			
		<div class="actions">
			<input type="button" class="primaryAction" name="btnSave" id="btnSave" value="Submit" onclick="saveComment('#form.id#')"/>
			<input type="hidden" name="commentId" id="commentId" value="#form.id#"/>
		</div>
	</cfif>
	<table>
		<tr>
			<th>Property</th>
			<th>Content</th>
			<cfif listfind(currentRole.permissions, "manage_comments")>
			<th>Action</th>			
			</cfif>
		</tr>
	<cfloop from="#startIndex#" to="#arrayLen(recentComments)#" index="i" >
		<cfset objComment = recentComments[i]>
		<tr>
			<td <cfif NOT i mod 2>class="alternate"</cfif>>
				<b>Name:</b>#objComment.getCreatorName()#<br/>
				<b>Email:</b>#objComment.getCreatorEmail()#<br/>
				<cfif len(objComment.getCreatorURL())>
				<b>Website:</b><a href="#objComment.getCreatorURL()#" target="_blank">#objComment.getCreatorURL()#</a></br/>
				</cfif>
				<b>Created :</b>#dateFormat(objComment.getCreatedOn(),"mm/dd/yyyy")#
			</td>
			<td <cfif NOT i mod 2>class="alternate"</cfif>>
				#objComment.getContent()#
			</td>
			<cfif listfind(currentRole.permissions, "manage_comments")>
			<td <cfif NOT i mod 2>class="alternate"</cfif>>
				<a href="javascript:editComment('#objComment.getId()#')">Edit</a> | 
				<a href="javascript:deleteComment('#objComment.getId()#')">Delete</a> 
				<cfif not objComment.getApproved()>
				|
				<a href="javascript:approveComment('#objComment.getId()#')">Approve</a>
				</cfif> 
			</td>			
			</cfif>
		</tr>
	</cfloop>
	</table>
	<cfif form.page gt 1>
		<a href="javascript:moveTo(#form.page-1#)">&lt;&lt; Prev</a>
	</cfif>	
	<cfif form.page lt totalpage>
		<a href="javascript:moveTo(#form.page+1#)">Next &gt;&gt;</a>
	</cfif>
	<div class="actions">
		<input type="hidden" name="primaryAction" value=""/>
		<input type="hidden" name="id" value=""/>
		<input type="hidden" name="owner" value="recentcomments" />
		<input type="hidden" value="showrecentcomments" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="Comments" name="selected" />
		<input type="hidden" value="#form.page#" name="page"/>
	</div>
</form>
</cfoutput>