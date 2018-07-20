# RowanSample6
Refinement of original work done in [RowanSample5 project](https://github.com/dalehenrich/RowanSample5)

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


```
### Simulate SETT output
```
# To start fresh:
#   rm -rf $GS_HOME/shared/repos/RowanSample6/sett/src/RowanSample6*
./newBuild_SystemUser_create_sett
```
