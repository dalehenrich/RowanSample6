Class {
	#name : 'RedClass1',
	#superclass : 'Object',
	#instVars : [
		'ivar1'
	],
	#gs_constraints : [
		[
			'ivar1',
			'RedSubclass1'
		]
	],
	#category : 'RowanSample6-Red1-Core'
}

{ #category : 'accessing' }
RedClass1 >> red1 [ ^1
]
