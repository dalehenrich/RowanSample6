Class {
	#name : 'RowanSample6ProjectBootstrapSupport',
	#superclass : 'RowanSample6Tools',
	#category : 'RowanSample6-Tools'
}

{ #category : 'private' }
RowanSample6ProjectBootstrapSupport >> _createSymbolDictionariesFor: userProfile [

	| symDicts |
	GsObjectSecurityPolicy 
		setCurrent: userProfile defaultObjectSecurityPolicy 
		while: [	
			symDicts := #(#Red #Yellow #Blue #Application ) 
				collect: [:name | SymbolDictionary new
					name: name;
					yourself ] ].
	 ^ symDicts

]

{ #category : 'bootstrap' }
RowanSample6ProjectBootstrapSupport >> addPackageMapSpecsToConfiguration: configurationUrl forGroups: groupNames [
	| utils config visitor |

	utils := Rowan fileUtilities.

	config := configurationUrl asRwUrl asConfiguration.

	visitor := RwProjectLoadConfigurationVisitor new
		platformAttributes:  Rowan platformConfigurationAttributes;
		groupNames: groupNames;
		yourself.
	visitor visit: config.

	visitor packageNames do: [:packageName |
		| symbolDictName |
		(packageName beginsWith: 'RowanSample6-Blue')
			ifTrue: [ symbolDictName := 'Blue' ].
		(packageName beginsWith: 'RowanSample6-Red')
			ifTrue: [ symbolDictName := 'Red' ].
		(packageName beginsWith: 'RowanSample6-Yellow')
			ifTrue: [ symbolDictName := 'Yellow' ].
		config
			conditionalPackageMapSpecsAtGemStoneUserId: 'allusers'  andPackageName: packageName setSymbolDictNameTo: symbolDictName ].

	config exportToUrl: configurationUrl

]

{ #category : 'bootstrap' }
RowanSample6ProjectBootstrapSupport >> createBootstrapProjectForSettSpecUrl: settProjectSpecUrl bootstrapSpecUrl: bootstrapProjectSpecUrl defaultGroupName: defaultGroupName globalsGroupName: globalsGroupName globalsUserId: globalsUserId defaultSymbolDictName: defaultSymbolDictName [
	| settProjectDefinition projectDefinitionSet configExportMap bootstrapProjectDefinition utils exportUrl dirPath |

	utils := Rowan fileUtilities.

	settProjectDefinition := Rowan projectTools create createProjectDefinitionFromSpecUrl: settProjectSpecUrl.
	projectDefinitionSet := Rowan projectTools read readProjectSetForProjectDefinition: settProjectDefinition.

	configExportMap := Rowan projectTools reconcile
		reconcileGlobalClassExtensionsForProjectDefinitionSet: projectDefinitionSet
		defaultGroupName: defaultGroupName
		globalsGroupName: globalsGroupName
		globalsUserId: globalsUserId.

	bootstrapProjectDefinition := Rowan projectTools create createProjectDefinitionFromSpecUrl: bootstrapProjectSpecUrl.

	exportUrl := 'file:', bootstrapProjectDefinition repositoryRootPath , utils pathNameDelimiter , 
		bootstrapProjectDefinition configsPath, utils pathNameDelimiter.

	configExportMap keysAndValuesDo: [:config :ignored |
		config
			conditionalPackageMapSpecsAtGemStoneUserId: 'allusers' setDefaultSymbolDictNameTo:defaultSymbolDictName.
		config exportToUrl: exportUrl  ].

	dirPath := bootstrapProjectDefinition repositoryRootPath , utils pathNameDelimiter , 
		bootstrapProjectDefinition repoPath.
	utils ensureDirectoryExists: dirPath.
	utils
		writeStreamFor: 'properties.st'
		in: dirPath
		do: [ :fileStream | fileStream nextPutAll: '{ #format : ''tonel''}' ].	

	"transfer packages from settProjectDefinition ... after reconcile ... so that we can write the packages in a separate src dir"

	settProjectDefinition packages values do: [:packageDef |
		bootstrapProjectDefinition addPackage: packageDef ].

	Rowan projectTools write writeProjectDefinition: bootstrapProjectDefinition

]

{ #category : 'bootstrap' }
RowanSample6ProjectBootstrapSupport >> createBootstrapUsersAndGroups [
	"Two users UserCurator and GlobalsCurator and two groups ApplicationModificationGroup and GlobalsModificationGroup ... on the off chance that we
		end up with more application users"

	"Should be run as SystemUser"

	| symDicts |

"create groups"
	  (AllGroups includes: 'GlobalsModificationGroup')
		ifFalse: [AllGroups add: 'GlobalsModificationGroup' ].
	  SystemObjectSecurityPolicy group: 'GlobalsModificationGroup' authorization: #write.

	  (AllGroups includes: 'ApplicationModificationGroup')
		ifFalse: [AllGroups add: 'ApplicationModificationGroup' ].

"create users"
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

"add users to groups"
	  (AllUsers userWithId: 'GlobalsCurator') 
		addGroup: 'GlobalsModificationGroup';
		addGroup: 'DataCuratorGroup'.
	  (AllUsers userWithId: 'UserCurator') 
		addGroup: 'ApplicationModificationGroup'.

"install #rowanCompile ... needed by Jadeite for now ... create symbol dictionaries"
	#( 'GlobalsCurator' 'UserCurator' )
	do: [:userId |
		| userProfile |
		userProfile := AllUsers userWithId: userId.
		GsObjectSecurityPolicy 
			setCurrent: userProfile defaultObjectSecurityPolicy 
			while: [ (userProfile objectNamed: 'UserGlobals') at: #rowanCompile put: true ].
		userId = 'UserCurator'
			ifTrue: [ symDicts := self _createSymbolDictionariesFor: userProfile ] ].

"install symbol dictionaries for each user"
	#( 'GlobalsCurator' 'UserCurator' )
	do: [:userId |
		| userProfile symbolList |
		userProfile := AllUsers userWithId: userId.
		GsObjectSecurityPolicy 
			setCurrent: userProfile defaultObjectSecurityPolicy 
			while: [
				symbolList := userProfile symbolList.
				symDicts do: [:newDict |
					userProfile insertDictionary: newDict at: symbolList size ].
				Rowan projectTools browser addRowanSymbolDictionariesToPersistentSymbolListFor: userProfile ] ].

]

{ #category : 'bootstrap' }
RowanSample6ProjectBootstrapSupport >> removeBootstrapPackages [

	self _removePackagesFor: 'bootstrap'

]
