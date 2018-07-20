
run
	| projectName projectDefinition packageNames utils dirPath |
	projectName := 'RowanSample6'.
	packageNames := { }.
	1 to: 2 do: [:index |
		#('Red' 'Yellow' 'Blue')
		do: [:user |
			packageNames 
				add: 'RowanSample6-', user, index  printString, '-Core';
				add: 'RowanSample6-', user, index printString, '-Extensions' ] ].
	projectDefinition := Rowan projectTools create
		createProjectDefinitionFromSpecUrl: RowanSample6_Spec_Url.
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

%
commit
