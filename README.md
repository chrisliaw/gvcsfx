
Generic Version Control System - JavaFX as GUI
==============================================

Version Control System (VCS) is a fantastic tool for developer to work on the same team. Changes between each developers can be independently tested and further integrates into complete system.

GIT has been the common and well accepted tool for this purpose, but it might have few traps for new comer, especially when code is conflicted and merged required. It is a daunting task for new comer sometimes. 

GVCSFx trying to provide a more natural workflow based on intend of the developer instead of independent advanced function of the GIT. The GUI trying to suggest a least resistance road to achieve an objective. 

For example when developer is developing on development branch and there is an urgent need to switch to a branch. Git suggested command 'stash' to be used but stash is easy however restore of stash is not, especially when there is a conflict on the file that is in development compare to the one already in Git. You will know if you have been bitten by this beast.

Hence the opinioned way to restore to stash is to a new branch so that a new development branch is automatically created for changes that is yet to be committed and developer can now in peace of mind know the changes shall be in new branch later and the normal merge workflow between two branches is streamlined.

Other features includes:
* Workspace management
  * Allow git workspaces tie to particular project. Single project might have multiple different git workspaces
  * Filter of project and only focus on the registered workspaces under a particular project
  * Remove workspace and empty project (via 'Delete' key or context menu)
* Commit workflow
  * No need separate 'add' command. Any file selected on the table view shall be added automatically before commit and rollback when commit failed
  * Double click to show diff of the file compare to already in version control
  * Right-click Context Menu
    * Add extension/files into .gitignore
    * Revert changes of particular files from HEAD
    * Take the file out from version control (wrongly check in)
  * Stash existing changes and restore the stash (at branch tab) into new branch instead of the original branch
* Ignore rules (.gitignore)
  * Text editor free editing of the rules
* Branches
  * Create new branch
  * Merge branch with current branch (context menu)
  * Delete branch (context menu)
* Tag
  * Checkout tag into new branch 
  * Double click show tag info
  * Arrange tag by creation date
  * Show tag created on when and by who
  * Checkout tag into new branch (context menu)
  * Delete of tag (via keyboard 'Delete' key)
* Logs
  * Show date, subject and committer
  * Double click on log show details
  * Copy subject (copy the commit message so that can paste into commit message in the commit screen) (context menu)
* Repository
  * Add/remove repository (Delete via keyboard 'Delete' key)
  * Push, optional together with tag to the repository
  * Pull from the repository


To be implemented
=================

* Global / Local configurations (httpVerify, author name, email etc)
* View pending changes compare to remote server - allow cherry-pick operation
* Conflicted files and status
* Sort by date/committer on logs






