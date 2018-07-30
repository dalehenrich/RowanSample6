Class {
	#name : 'BlueClass1',
	#superclass : 'Object',
	#instVars : [
		'ivar1',
		'ivar3'
	],
	#gs_constraints : [
		[
			'ivar1',
			'BlueSubclass1'
		]
	],
	#category : 'RowanSample6-Blue1-Core'
}

{ #category : 'accessing' }
BlueClass1 >> blue1 [ ^1
]
