Class {
	#name : 'BlueClass1',
	#superclass : 'Object',
	#instVars : [
		'ivar5',
		'ivar1'
	],
	#gs_constraints : [
		[
			'ivar5',
			'Number'
		],
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
