Class {
	#name : 'YellowClass1',
	#superclass : 'Object',
	#instVars : [
		'ivar1'
	],
	#gs_constraints : [
		[
			'ivar1',
			'YellowSubclass1'
		]
	],
	#category : 'RowanSample6-Yellow1-Core'
}

{ #category : 'accessing' }
YellowClass1 class >> initialize [ "no-op"
]
{ #category : 'accessing' }
YellowClass1 >> yellow1 [ ^1
]
