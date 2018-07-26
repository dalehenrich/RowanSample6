Class {
	#name : 'BlueClass2',
	#superclass : 'Object',
	#instVars : [
		'ivar1'
	],
	#gs_constraints : [
		[
			'ivar1',
			'BlueSubclass2'
		]
	],
	#category : 'RowanSample6-Blue2-Core'
}

{ #category : 'accessing' }
BlueClass2 >> blue2 [ ^100
]
