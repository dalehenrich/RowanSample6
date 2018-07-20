Class {
	#name : 'RowanSample6ConversionSupport',
	#superclass : 'RowanSample6Tools',
	#category : 'RowanSample6-Tools'
}

{ #category : 'sett' }
RowanSample6ConversionSupport >> setDefaultSymbolDictNameForConfiguration: configurationUrl to: defaultSymbolDictName forUserId: userId [
	| utils config  |

	utils := Rowan fileUtilities.

	config := configurationUrl asRwUrl asConfiguration.

	config conditionalPackageMapSpecsAtGemStoneUserId: userId setDefaultSymbolDictNameTo: defaultSymbolDictName.

	config exportToUrl: configurationUrl

]
