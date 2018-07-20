
run
  (AllGroups includes: 'GlobalsModificationGroup')
    ifFalse: [AllGroups add: 'GlobalsModificationGroup' ].
  SystemObjectSecurityPolicy group: 'GlobalsModificationGroup' authorization: #write.

  (AllGroups includes: 'ApplicationModificationGroup')
    ifFalse: [AllGroups add: 'ApplicationModificationGroup' ].
%
commit

run
  #( 'GlobalsCurator' 'UserCurator' )
    do: [:userId |
      | newUser |
      newUser := AllUsers userWithId: userId ifAbsent: [ nil ].
      newUser
        ifNil: [
          | securityPolicy worldAuthorization |
          worldAuthorization := #read.
         securityPolicy := GsObjectSecurityPolicy new
	    ownerAuthorization: #write;
	    worldAuthorization: worldAuthorization;
	    yourself.
          System commit.
           newUser := AllUsers 
            addNewUserWithId: userId
            password: 'swordfish'
            defaultObjectSecurityPolicy: securityPolicy
            privileges: #('CodeModification'
              'UserPassword'
              'OtherPassword'
              'GarbageCollection'
              'SystemControl'
              'SessionAccess'
              'FileControl'
              'SessionPriority')
	    inGroups: #().
          securityPolicy owner: newUser ].
      System commit ].
%
commit

run
  (AllUsers userWithId: 'GlobalsCurator') 
	addGroup: 'GlobalsModificationGroup';
	addGroup: 'DataCuratorGroup'.
  (AllUsers userWithId: 'UserCurator') 
	addGroup: 'ApplicationModificationGroup'.
%
commit

