Class {
	#name : 'RowanSample6ConversionSupport',
	#superclass : 'RowanSample6Tools',
	#category : 'RowanSample6-Tools'
}

{ #category : 'updating' }
RowanSample6ConversionSupport >> adoptStagingProjectNamed: stagingProjectName for: projectName fromProjectSpecUrl: projectSpecUrl isGlobalsUser: isGlobalsUser projectSymbolDictionaries: projectSymbolDictionaries [

	| stagingProjectDefinition projectTools packageNames diskProjectDefinition projectSetDefinitionToLoad projectDefinitionToLoad |
 
	packageNames := {}.
	isGlobalsUser
		ifTrue: [ packageNames add: 'Staging-Globals' ]
		ifFalse: [ 
			projectSymbolDictionaries do: [:symDict |
				symDict ~~ Globals
					ifTrue: [ 
						packageNames add: 'Staging-', symDict name asString ] ] ].

	projectTools := Rowan projectTools.

	"Create the staging project definition - in memory only ... disk image not created, nor needed"
	stagingProjectDefinition := Rowan projectTools create
		createDiskBasedProjectDefinition: stagingProjectName 
		packageNames: packageNames 
		format: 'tonel'
		root: '$ROWAN_PROJECTS_HOME'.
	isGlobalsUser
		ifTrue: 
			[stagingProjectDefinition
				setSymbolDictName: 'Globals' forPackageNamed: 'Staging-Globals' ]
		ifFalse: [ 
			projectSymbolDictionaries do: [:symDict |
				symDict ~~ Globals
					ifTrue: [
						stagingProjectDefinition
							setSymbolDictName: symDict name asString forPackageNamed: 'Staging-', symDict name asString ] ] ].

	projectTools load loadProjectDefinition: stagingProjectDefinition.

	"Read RowanSample5 project from disk --- and force all packages to be loaded into Globals"
	diskProjectDefinition := Rowan projectTools create createProjectDefinitionFromSpecUrl: projectSpecUrl.
	diskProjectDefinition packageNames do: [:packageName |
		diskProjectDefinition setSymbolDictName: 'Globals' forPackageNamed: packageName ].

	"Adopt symbol dicts into staging project"
	projectSetDefinitionToLoad := Rowan projectTools read readProjectSetForProjectDefinition: diskProjectDefinition.
	UserGlobals
		at: #RowanSample5_client_projectSetDefinitionToLoad
		put: projectSetDefinitionToLoad.

	"adopt Globals extension methods and all application symbol dictionaries"

	projectDefinitionToLoad := projectSetDefinitionToLoad projectNamed: projectName ifAbsent: [].
	isGlobalsUser ifTrue: [ 
		projectDefinitionToLoad
		packages values do: [:packageDefinition |
			packageDefinition classExtensions values do: [:classExtension |
				(Globals at: classExtension name asSymbol ifAbsent: []) ifNotNil: [
					classExtension instanceMethodDefinitions valuesDo: [:methodDefinition |
						Rowan packageTools adopt
							adoptMethod: methodDefinition selector inClassNamed: classExtension name isMeta: false intoPackageNamed: 'Staging-Globals' ].
					classExtension classMethodDefinitions valuesDo: [[:methodDefinition |
						Rowan packageTools adopt
							adoptMethod: methodDefinition selector inClassNamed: classExtension name isMeta: true intoPackageNamed: 'Staging-Globals']]]]]]
		ifFalse: [ 
			projectSymbolDictionaries do: [:dict |
			dict name == #Globals
				ifFalse: [ 
					Rowan packageTools adopt
						adoptSymbolDictionary: dict
						intoPackageNamed: 'Staging-', dict name asString ] ] ].

	stagingProjectDefinition packages values do: [:pkgDefinition |
	    pkgDefinition classDefinitions values do: [:classDefinition |
	        pkgDefinition removeClassDefinition: classDefinition ].
	    pkgDefinition classExtensions values do: [:classExtension |
        	pkgDefinition removeClassExtension: classExtension ]].

	projectSetDefinitionToLoad
		addProject: stagingProjectDefinition.

]

{ #category : 'sett' }
RowanSample6ConversionSupport >> setDefaultSymbolDictNameForConfiguration: configurationUrl to: defaultSymbolDictName forUserId: userId [
	| utils config  |

	utils := Rowan fileUtilities.

	config := configurationUrl asRwUrl asConfiguration.

	config conditionalPackageMapSpecsAtGemStoneUserId: userId setDefaultSymbolDictNameTo: defaultSymbolDictName.

	config exportToUrl: configurationUrl

]
