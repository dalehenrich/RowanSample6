
run
	| settProjectDefinition projectDefinitionSet configExportMap reconcileProjectDefinition utils |

	utils := Rowan fileUtilities.

	settProjectDefinition := Rowan projectTools create createProjectDefinitionFromSpecUrl: RowanSample6_Spec_Url_sett.
	projectDefinitionSet := Rowan projectTools read readProjectSetForProjectDefinition: settProjectDefinition.

	configExportMap := Rowan projectTools reconcile
		reconcileGlobalClassExtensionsForProjectDefinitionSet: projectDefinitionSet.

	reconcileProjectDefinition := Rowan projectTools create createProjectDefinitionFromSpecUrl: RowanSample6_Spec_Url_reconcile.

	exportUrl := 'file:', reconcileProjectDefinition repositoryRootPath , utils pathNameDelimiter , 
		reconcileProjectDefinition configsPath, utils pathNameDelimiter.

	configExportMap keysAndValuesDo: [:config :ignored |
		config exportUrl  ].

"need to transfer packages from sett to reconcile project defs"


	projectTools write writeProjectDefinition: reconcileProjectDefinition
%
commit
