Extension { #name : 'RwProjectTool' }

{ #category : '*rowansample6-tools' }
RwProjectTool class >> bootstrap_sample6 [

	^ RowanSample6ProjectBootstrapSupport new

]

{ #category : '*rowansample6-tools' }
RwProjectTool class >> convert_sample6 [

	^ RowanSample6ConversionSupport new

]

{ #category : '*rowansample6-tools' }
RwProjectTool class >> create_sample6 [

	^ RowanSample6ProjectCreationSupport new

]

{ #category : '*rowansample6-tools' }
RwProjectTool class >> load_sample6 [

	^ RowanSample6ProjectLoadSupport new

]
