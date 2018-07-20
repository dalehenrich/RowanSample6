
run
	| settProjectDefinition projectDefinitionSet configExportMap reconcileProjectDefinition utils exportUrl |

	utils := Rowan fileUtilities.

	settProjectDefinition := Rowan projectTools create createProjectDefinitionFromSpecUrl: RowanSample6_Spec_Url_sett.
	projectDefinitionSet := Rowan projectTools read readProjectSetForProjectDefinition: settProjectDefinition.

	configExportMap := Rowan projectTools reconcile
		reconcileGlobalClassExtensionsForProjectDefinitionSet: projectDefinitionSet.

	reconcileProjectDefinition := Rowan projectTools create createProjectDefinitionFromSpecUrl: RowanSample6_Spec_Url_reconcile.

	exportUrl := 'file:', reconcileProjectDefinition repositoryRootPath , utils pathNameDelimiter , 
		reconcileProjectDefinition configsPath, utils pathNameDelimiter.

	configExportMap keysAndValuesDo: [:config :ignored |
		config exportToUrl: exportUrl  ].

	"transfer packages from settProjectDefinition ... after reconcile ... so that we can write the packages in a separate src dir"

	settProjectDefinition packages values do: [:packageDef |
		reconcileProjectDefinition addPackage: packageDef ].

	Rowan projectTools write writeProjectDefinition: reconcileProjectDefinition
%
commit
