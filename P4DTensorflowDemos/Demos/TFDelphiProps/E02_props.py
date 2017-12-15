# Display the Properties content
print (P4DProps)
# Get single property
print (P4DProps.Value['integer1'])
print (P4DProps.Value['integer2'])

# Change one of the properties
P4DProps.Value['integer1'] = 111
P4DProps.Value['integer2'] = 222
# By reassigning the same object, we force the OnChange event
# That will update the Delphi controls
P4DProps.Value = P4DProps.Value
