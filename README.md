# RowanSample6
This project is an example of the process used to convert an existing GemStone/S application to use git for source code control and Rowan for source code control.

This project is structured in such a way that all of the code and package artifacts are generated from scripts so that it can be adapted to simulate any number actual application structures.

The sett directory contains the application packages that have been converted from the original source code control system to tonel format.

The bootstrap directory contains the application packages needed to reproduce the starting state of the existing application stone, emulating the original symbol dictionary structure and set of users.

1. [Setup](#setup) - process used to create or update the project artifacts (packages and configurations)
2. [Reconcile](#reconcile) - process used to adjust package structure produced by SETT to match Rowan requirements
3. [Update](#update) - process used to load an application using Rowan into a stone where the classes and methods already exist

## Setup
This section mainly covers the creation of a stone that mirrors the symbol dictionary and user structure of an existing GemStone/S application.

### Create rowan_sample6_3215 stone
```
createStone -g rowan_sample6_3215 3.2.15
cd $GS_HOME/server/stones/rowan_sample6_3215

cat -- >> custom_stone.env << EOF
export ROWAN_PROJECTS_HOME=\$GS_HOME/shared/repos
EOF

stopNetldi rowan_sample6_3215
startNetldi rowan_sample6_3215

ln -s $GS_HOME/shared/repos/RowanSample6/gsdevkit/stone/newBuild_SystemUser_create_sett
ln -s $GS_HOME/shared/repos/RowanSample6/gsdevkit/stone/newBuild_SystemUser_create_bootstrap
ln -s $GS_HOME/shared/repos/RowanSample6/gsdevkit/stone/newBuild_SystemUser_reconcile_sett
ln -s $GS_HOME/shared/repos/RowanSample6/gsdevkit/stone/newBuild_SystemUser_update_sett
```
### Create generated SETT package and configuration structure
Create new package structure in `sett/src` and new configuration in `sett/configs`, simulating what would have been generated using SETT:

```smalltalk
  Rowan projectTools create_sample6 removeSettPackages.
  Rowan projectTools create_sample6
    createSettProjectForSpecUrl: 'file:$ROWAN_PROJECTS_HOME/RowanSample6/specs/RowanSample6_sett.ston'
```

Use the following script to run the script using GsDevKit:

```
./newBuild_SystemUser_create_sett
```
### Create bootstrap code and create initial version of stone
In order to simulate the application structure in the application stone prior to the introduction of Rowan, we have to use Rowan to create the structures, users and symbol dictionaries. In an actual installation, this step can be skipped.

For this project the packages are distributed across three different symbol dictionaries: Red, Yellow, and Blue ... extension methods for classes in the Globals symbol dictionary need to be loaded by our GlobalsCurator user. Application code is loaded by the UserCurator.

The following script creates the bootstrap package and configuration structure:
```smalltalk
  Rowan projectTools bootstrap_sample6 removeBootstrapPackages.
"reconcile global extensions ... moving global extension methods to separate packages"
  Rowan projectTools bootstrap_sample6
    createBootstrapProjectForSettSpecUrl: 'file:$ROWAN_PROJECTS_HOME/RowanSample6/specs/RowanSample6_sett.ston' 
    bootstrapSpecUrl: 'file:$ROWAN_PROJECTS_HOME/RowanSample6/specs/RowanSample6_bootstrap_core.ston' 
    defaultGroupName: 'core' 
    globalsGroupName: 'globals' 
    globalsUserId: 'GlobalsCurator' 
    defaultSymbolDictName: 'Application'
"Assign core packages to one of three symbol dictionaries: Red, Yellow, or Blue"
  Rowan projectTools bootstrap_sample6
    addPackageMapSpecsToConfiguration: 'file:$ROWAN_PROJECTS_HOME/RowanSample6/bootstrap/configs/Default.ston' 
    forGroups: { 'core' }

```
Before loading the bootstrap packages into the stone, we have to create users and symbol dictionaries to match our original stone structure (run as DataCurator):
```Smalltalk
Rowan projectTools create_sample6 createBootstrapUsersAndGroups
```

Use the following script to run the script using GsDevKit:
```
./newBuild_SystemUser_create_bootstrap
```
At this point you can use Jadeite to look at the symbol dictionaries for both `UserCurator` and `GlobalsCurator`.

## Reconcile
This section assumes that you have used SETT to convert your source code into Tonel format and are now ready to update a stone that contains your application so that Rowan and git can be used to manage the source code of your application moving forward.

### Reconcile the Sett code: move class extensions for Globals classes into separate packages
Since a Rowan package must be loaded into the symbol dictionary where the extension class resides, it is necessary to split out extension methods for classes that are not all a member of the same symbol dictionary. 
The most common case is the Kernel GemStone class in the Globals symbol dictionary.
The following expression scans all of the packages in the given project and moves the extension methods for Globals classes into separate packages:
```smalltalk
Rowan projectTools reconcile
	reconcileGlobalClassExtensionsForProjectFromSpecUrl: 'file:$ROWAN_PROJECTS_HOME/RowanSample6/specs/RowanSample6_sett.ston'
	defaultGroupName: 'core' 
	globalsGroupName: 'globals'  
	globalsUserId: 'GlobalsCurator' 
	writeProject: true.
```
The new package is created by tacking `-Globals` onto the package name of the original package.

### Adjust Sett configuration: set defaultSymbolDictName to 'Application'
In this case, we've decided that instead of loading each of the packages into separate symbol dictionaries, we will consolidate all of the application code in a single symbol dictionary call `Application`. The following code, updates the configuration with this information:
```smalltalk
  Rowan projectTools convert_sample6
	setDefaultSymbolDictNameForConfiguration: 'file:$ROWAN_PROJECTS_HOME/RowanSample6/sett/configs/Default.ston' 
	to: 'Application' 
	forUserId: 'allusers'
```
Use the following to run the script against GsDevKit stones (covers [reconcile](#reconcile-the-sett-code-move-class-extensions-for-globals-classes-into-separate-packages) and [adjust](#adjust-sett-configuration-set-defaultsymboldictname-to-applicationn)):
```
./newBuild_SystemUser_reconcile_sett
```
Note that the `sett/src`and `sett/configs` directories will be modified when the above script runs. If you want to preserve the newly generated code, I suggest that you work on a branch to preserve the state of the master branch.

## Update
The [Reconcile](#reconcile) operation only needs to be done once ... in this project you should `checkout` the `reconcile_sett` branch where the results of the [reconcile](#reconcile-the-sett-code-move-class-extensions-for-globals-classes-into-separate-packages) have been saved.

The update process involves creating a staging project and `adopting` the code in the image into the staging project so that the SETT package structure can be loaded into the stone.

### Adopt existing application classes and methods into a Staging project
In general the `adopt` process is used to create a single package in the staging project for each symbol dictionary used in the application. If extensions to class in Globals is involved, the process must be split into two operations one involving the Globals symbol dictionary and one involving the rest of the symbol dictionaries ... If multiple users with conflicting permissions are used to manage different symbol dicitonaries, the a single adopt call per user needs to be used.

Here's the code used to adopt our project:
```smalltalk
"As UserCurator"
| projectSetDefinitionToLoad |
  projectSetDefinitionToLoad := Rowan projectTools convert_sample6
	adoptStagingProjectNamed: 'Staging_RowanSample5_core' 
	for: 'RowanSample6_core' 
	fromProjectSpecUrl: 'file:$ROWAN_PROJECTS_HOME/RowanSample6/specs/RowanSample6_sett_core.ston' 
	isGlobalsUser: false 
	projectSymbolDictionaries: {Red . Yellow. Blue . Globals }.
  UserGlobals 
    at: #'RowanSample6_core_projectSetDefinitionToLoad'
    put: projectSetDefinitionToLoad
```
```smalltalk
"As GlobalsCurator"
| projectSetDefinitionToLoad |
  projectSetDefinitionToLoad := Rowan projectTools convert_sample6
	adoptStagingProjectNamed: 'Staging_RowanSample5_globals' 
	for: 'RowanSample6_globals' 
	fromProjectSpecUrl: 'file:$ROWAN_PROJECTS_HOME/RowanSample6/specs/RowanSample6_sett_globals.ston'
	isGlobalsUser: true 
	projectSymbolDictionaries: {Red . Yellow. Blue . Globals }.
  UserGlobals 
    at: #'RowanSample6_globals_projectSetDefinitionToLoad'
    put: projectSetDefinitionToLoad
```
The `projectSetDefinitionToLoad` is stashed in UserGlobals, because it is used in the finale load, where both the staging project and application project are needed"
### Load application and staging project ... disown staging project
```smalltalk
  "as UserCurator"
  | projectSetDefinitionToLoad |
  projectSetDefinitionToLoad := UserGlobals at: #'RowanSample6_core_projectSetDefinitionToLoad'.
  Rowan projectTools load loadProjectSetDefinition: projectSetDefinitionToLoad.
  Rowan projectTools load _markProjectSetNotDirty: projectSetDefinitionToLoad.
  Rowan projectTools disown
    disownProjectNamed: 'Staging_RowanSample5_core'.
```
```smalltalk
  "as GlobalsCurator"
  | projectSetDefinitionToLoad |
  projectSetDefinitionToLoad := UserGlobals at: #'RowanSample6_globals_projectSetDefinitionToLoad'.
  Rowan projectTools load loadProjectSetDefinition: projectSetDefinitionToLoad.
  Rowan projectTools load _markProjectSetNotDirty: projectSetDefinitionToLoad.
  Rowan projectTools disown
    disownProjectNamed: 'Staging_RowanSample5_globals'.
```

Use the following to run the script against GsDevKit stones
```
./newBuild_SystemUser_update_sett
```

