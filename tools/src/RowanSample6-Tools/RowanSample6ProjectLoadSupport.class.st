Class {
	#name : 'RowanSample6ProjectLoadSupport',
	#superclass : 'RowanSample6Tools',
	#category : 'RowanSample6-Tools'
}

{ #category : 'load support' }
RowanSample6ProjectLoadSupport >> fullFeaturedLoad: theLoadBlock [

  ^ self fullFeaturedLoad: theLoadBlock classNamesToDelete: #()
]

{ #category : 'load support' }
RowanSample6ProjectLoadSupport >> fullFeaturedLoad: theLoadBlock classNamesToDelete: classNamesToDelete [

  | orphanedClasses deferredInstanceMigrator |
  orphanedClasses := IdentitySet new.
  
  deferredInstanceMigrator := RwGsDeferredInstanceMigrator noMigration.
  [ theLoadBlock value: deferredInstanceMigrator ]
    on: RwDeleteClassFromSystemNotification, RwExecuteClassInitializeMethodsAfterLoadNotification
    do: [:ex | 
      (ex isKindOf: RwDeleteClassFromSystemNotification)
        ifTrue: [
          | candidateClass |
          candidateClass := ex candidateClass.
          (classNamesToDelete includes: candidateClass name)
            ifTrue: [
              "delete the class" 
              GsFile gciLogServer: 'deleting class ', candidateClass name printString.
              ex pass ].
          "do not delete the class"
          GsFile gciLogServer: 'Not deleting class ', candidateClass name printString.
          orphanedClasses add: candidateClass.
          ex resume: false ]
        ifFalse: [ 
          "assume RwExecuteClassInitializeMethodsAfterLoadNotification"
          GsFile gciLogServer: 'Skipped #initalize for class ', ex candidateClass name printString.
          ex resume: false "do not run initializers ... initialization will be done separate from load" ] ].
  deferredInstanceMigrator classesToMigrate size > 0
    ifTrue: [
      GsFile gciLogServer:
        deferredInstanceMigrator classesToMigrate size printString, 
        ' classes with new class varsions '.
      deferredInstanceMigrator classesToMigrate do: [:class |
        GsFile gciLogServer: '  ', class name printString ] ]
    ifFalse: [ GsFile gciLogServer: 'No classes with new class versions.' ].
  ^ orphanedClasses

]
