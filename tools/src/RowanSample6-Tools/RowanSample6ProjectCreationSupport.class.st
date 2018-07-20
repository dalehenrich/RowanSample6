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
RowanSample6ProjectCreationSupport >> createBootstrapProjectForSettSpecUrl: settProjectSpecUrl bootstrapSpecUrl: bootstrapProjectSpecUrl defaultGroupName: defaultGroupName globalsGroupName: globalsGroupName globalsUserId: globalsUserId defaultSymbolDictName: defaultSymbolDictName [
	| settProjectDefinition projectDefinitionSet configExportMap reconcileProjectDefinition utils exportUrl |

	utils := Rowan fileUtilities.

	settProjectDefinition := Rowan projectTools create createProjectDefinitionFromSpecUrl: settProjectSpecUrl.
	projectDefinitionSet := Rowan projectTools read readProjectSetForProjectDefinition: settProjectDefinition.

	configExportMap := Rowan projectTools reconcile
		reconcileGlobalClassExtensionsForProjectDefinitionSet: projectDefinitionSet
		defaultGroupName: defaultGroupName
		globalsGroupName: globalsGroupName
		globalsUserId: globalsUserId.

	reconcileProjectDefinition := Rowan projectTools create createProjectDefinitionFromSpecUrl: bootstrapProjectSpecUrl.

	exportUrl := 'file:', reconcileProjectDefinition repositoryRootPath , utils pathNameDelimiter , 
		reconcileProjectDefinition configsPath, utils pathNameDelimiter.

	configExportMap keysAndValuesDo: [:config :ignored |
		config
			conditionalPackageMapSpecsAtGemStoneUserId: 'allusers' setDefaultSymbolDictNameTo:defaultSymbolDictName.
		config exportToUrl: exportUrl  ].

	"transfer packages from settProjectDefinition ... after reconcile ... so that we can write the packages in a separate src dir"

	settProjectDefinition packages values do: [:packageDef |
		reconcileProjectDefinition addPackage: packageDef ].

	Rowan projectTools write writeProjectDefinition: reconcileProjectDefinition

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
RowanSample6ProjectCreationSupport >> removeBootstrapPackages [

	self _removePackagesFor: 'bootstrap'

]

{ #category : 'sett' }
RowanSample6ProjectCreationSupport >> removeSettPackages [

	self _removePackagesFor: 'sett'

]
