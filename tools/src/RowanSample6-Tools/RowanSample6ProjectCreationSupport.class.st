Class {
	#name : 'RowanSample6ProjectCreationSupport',
	#superclass : 'RwProjectTool',
	#category : 'RowanSample6-Tools'
}

{ #category : 'private' }
RowanSample6ProjectCreationSupport >> _removePackagesFor: subProject [

	Rowan projectTools git performOnServer: 'rm -rf $ROWAN_PROJECTS_HOME/RowanSample6/', subProject, '/src/RowanSample6*' logging: false

]

{ #category : 'bootstrap' }
RowanSample6ProjectCreationSupport >> addPackageMapSpecsToConfiguration: configurationUrl forGroups: groupNames [
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
RowanSample6ProjectCreationSupport >> createBootstrapProjectForSettSpecUrl: settProjectSpecUrl bootstrapSpecUrl: bootstrapProjectSpecUrl defaultGroupName: defaultGroupName globalsGroupName: globalsGroupName globalsUserId: globalsUserId defaultSymbolDictName: defaultSymbolDictName [
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
RowanSample6ProjectCreationSupport >> createBootstrapUsersAndGroups [
	"Two users UserCurator and GlobalsCurator and two groups ApplicationModificationGroup and GlobalsModificationGroup ... on the off chance that we
		end up with more application users"

	"Should be run as SystemUser"

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

"install #rowanCompile ... needed by Jadeite for now"
	#( 'GlobalsCurator' 'UserCurator' )
	do: [:userId |
		| userProfile |
		userProfile := AllUsers userWithId: userId.
		GsObjectSecurityPolicy 
			setCurrent: userProfile defaultObjectSecurityPolicy 
			while: [ 
				(userProfile objectNamed: 'UserGlobals') at: #rowanCompile put: true.
				userId = 'UserCurator'
					ifTrue: [ self createUserCuratorSymbolDictionaryFor: userProfile ] ] ]

]

{ #category : 'sett' }
RowanSample6ProjectCreationSupport >> createSettProjectForSpecUrl: projectSpecUrl [
	| projectName projectDefinition packageNames utils dirPath config |
	projectName := 'RowanSample6'.
	packageNames := { }.
	1 to: 2 do: [:index |
		#('Red' 'Yellow' 'Blue')
		do: [:user |
			packageNames 
				add: 'RowanSample6-', user, index  printString, '-Core';
				add: 'RowanSample6-', user, index printString, '-Extensions' ] ].
	projectDefinition := Rowan projectTools create
		createProjectDefinitionFromSpecUrl:projectSpecUrl.
	utils := Rowan fileUtilities.
	dirPath := projectDefinition repositoryRootPath , utils pathNameDelimiter , 
		projectDefinition repoPath.
	utils ensureDirectoryExists: dirPath.
	utils
		writeStreamFor: 'properties.st'
		in: dirPath
		do: [ :fileStream | fileStream nextPutAll: '{ #format : ''tonel''}' ].	
	projectDefinition addPackagesNamed: packageNames.
	1 to: 2 do: [:index |
		#('Red' 'Yellow' 'Blue')
		do: [:user |
			| classDefinition subclassDefinition packageName packageDefinition 
				extensionPackageName className subclassName classExtensionDefinition 
				methodSelector objectClassExtensionDefinition byteArrayClassExtensionDefinition |
			packageName := 'RowanSample6-', user, index printString, '-Core'.
			className := user, 'Class', index printString.
			subclassName := user, 'Subclass', index printString.
			classDefinition := RwClassDefinition
				newForClassNamed: className
				super: 'Object'
				instvars: #(ivar1)
				classinstvars: #()
				classvars: #()
				category: packageName
				comment: ''
				pools: #()
				type: 'normal'.
			classDefinition gs_constraints: { { 'ivar1' . subclassName } }.
			methodSelector := user asLowercase, index asString.
			classDefinition
				addInstanceMethodDefinition:
					(RwMethodDefinition
						newForSelector: methodSelector asSymbol
						protocol: 'accessing'
						source: methodSelector, ' ^1').

			subclassDefinition := RwClassDefinition
				newForClassNamed: subclassName
				super: className
				instvars: #(ivar2)
				classinstvars: #()
				classvars: #()
				category: packageName
				comment: ''
				pools: #()
				type: 'normal'.
			subclassDefinition gs_constraints: { { 'ivar2' . 'Association' } }.

			packageDefinition := projectDefinition packageNamed: packageName.
			packageDefinition 
				addClassDefinition: classDefinition;
				addClassDefinition: subclassDefinition. 

			"No external extension methods for Dark, since no write permissions"
			extensionPackageName := 'RowanSample6-', user, index printString, '-Extensions'.
			classExtensionDefinition := RwClassExtensionDefinition newForClassNamed: className.
			#('Red' 'Yellow' 'Blue')
				do: [:extensionUser |
					extensionUser ~= user
						ifTrue: [ 
							methodSelector :=  'ext', extensionUser, index printString.
							classExtensionDefinition
								addInstanceMethodDefinition:
									(RwMethodDefinition
										newForSelector: methodSelector asSymbol
										protocol: '*', extensionPackageName asLowercase
										source: methodSelector, ' ^2') ] ].
	"Object and ByteArray extension methods per user"
			methodSelector :=  'ext', user, index printString.
			objectClassExtensionDefinition := (RwClassExtensionDefinition newForClassNamed: 'Object')
				addInstanceMethodDefinition:
					(RwMethodDefinition
						newForSelector: methodSelector asSymbol
						protocol: '*', extensionPackageName asLowercase
						source: methodSelector, ' ^3');
				addClassMethodDefinition:
					(RwMethodDefinition
						newForSelector: methodSelector asSymbol
						protocol: '*', extensionPackageName asLowercase
						source: methodSelector, ' ^3');
				yourself.
			byteArrayClassExtensionDefinition := (RwClassExtensionDefinition newForClassNamed: 'ByteArray')
				addInstanceMethodDefinition:
					(RwMethodDefinition
						newForSelector: methodSelector asSymbol
						protocol: '*', extensionPackageName asLowercase
						source: methodSelector, ' ^4');
				addClassMethodDefinition:
					(RwMethodDefinition
						newForSelector: methodSelector asSymbol
						protocol: '*', extensionPackageName asLowercase
						source: methodSelector, ' ^4');
				yourself.
	"add the extensions to the package"
			packageDefinition := projectDefinition packageNamed: extensionPackageName.
			packageDefinition 
				addClassExtension: classExtensionDefinition;
				addClassExtension: objectClassExtensionDefinition;
				addClassExtension: byteArrayClassExtensionDefinition;
				yourself ] ].

	"write"
	Rowan projectTools write writeProjectDefinition: projectDefinition.

	config := RwProjectCompoundConfiguration new
	name: 'Default';
	projectName: projectName;
	packageNames: packageNames;
	comment: 'Generated by topaz/createProject_sett.gs';
	yourself.
	dirPath := projectDefinition repositoryRootPath , utils pathNameDelimiter , 
		projectDefinition configsPath, utils pathNameDelimiter.
	config exportToUrl: 'file:', dirPath

]

{ #category : 'bootstrap' }
RowanSample6ProjectCreationSupport >> createUserCuratorSymbolDictionaryFor: userProfile [

	| symbolList newDict |
	symbolList := userProfile symbolList.
	newDict := SymbolDictionary new
		name: #Application;
		yourself.
	userProfile insertDictionary: newDict at: symbolList size

]

{ #category : 'bootstrap' }
RowanSample6ProjectCreationSupport >> removeBootstrapPackages [

	self _removePackagesFor: 'bootstrap'

]

{ #category : 'sett' }
RowanSample6ProjectCreationSupport >> removeSettPackages [

	self _removePackagesFor: 'sett'

]
