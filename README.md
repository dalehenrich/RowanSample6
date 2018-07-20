# RowanSample6
This project is an example of the process used to convert an existing GemStone/S application to use git for source code control and Rowan for source code control.

This project is structured in such a way that all of the code and package artifacts are generated from scripts so that it can be adapted to simulate any number actual application structures.

The sett directory contains the application packages that have been converted from the original source code control system to tonel format.

The bootstrap directory contains the application packages needed to reproduce the starting state of the existing application stone, emulating the original symbol dictionary structure and set of users.

   
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

ln -s $GS_HOME/shared/repos/RowanSample6/gsdevkit/stone/newBuild_SystemUser_bootstrap
ln -s $GS_HOME/shared/repos/RowanSample6/gsdevkit/stone//newBuild_SystemUser_split_load
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
In order to simulate the application structure in the application stone prior to the introduction of Rowan, we have to use Rowan to create the structure and then remove the Rowan artifacts. In an actual installation, this step can be skipped.
```smalltalk
  Rowan projectTools create_sample6 removeBootstrapPackages.
  Rowan projectTools create_sample6
    createBootstrapProjectForSettSpecUrl: 'file:$ROWAN_PROJECTS_HOME/RowanSample6/specs/RowanSample6_sett.ston' 
    bootstrapSpecUrl: 'file:$ROWAN_PROJECTS_HOME/RowanSample6/specs/RowanSample6_bootstrap.ston' 
    defaultGroupName: 'core' 
    globalsGroupName: 'globals' 
    globalsUserId: 'GlobalsCurator' 
    defaultSymbolDictName: 'Application'
```

Use the following script to run the script using GsDevKit:
```
./newBuild_SystemUser_create_bootstrap
```
