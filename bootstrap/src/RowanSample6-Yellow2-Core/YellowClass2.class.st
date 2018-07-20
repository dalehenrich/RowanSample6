Class {
	#name : 'YellowClass2',
	#superclass : 'Object',
	#instVars : [
		'ivar1'
	],
	#gs_constraints : [
		[
			'ivar1',
			'YellowSubclass2'
		]
	],
	#category : 'RowanSample6-Yellow2-Core'
}

{ #category : 'accessing' }
YellowClass2 >> yellow2 [ ^1
]
