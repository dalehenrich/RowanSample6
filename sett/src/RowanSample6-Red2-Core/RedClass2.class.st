Class {
	#name : 'RedClass2',
	#superclass : 'Object',
	#instVars : [
		'ivar1'
	],
	#gs_constraints : [
		[
			'ivar1',
			'RedSubclass2'
		]
	],
	#category : 'RowanSample6-Red2-Core'
}

{ #category : 'accessing' }
RedClass2 >> red2 [ ^1
]
