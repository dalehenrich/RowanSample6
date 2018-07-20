Class {
	#name : 'RowanSample6Tools',
	#superclass : 'RwProjectTool',
	#category : 'RowanSample6-Tools'
}

{ #category : 'private' }
RowanSample6Tools >> _removePackagesFor: subProject [

	Rowan projectTools git performOnServer: 'rm -rf $ROWAN_PROJECTS_HOME/RowanSample6/', subProject, '/src/RowanSample6*' logging: false

]
