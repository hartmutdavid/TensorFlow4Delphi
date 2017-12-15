# Display the Properties content
print (P4DProps)
# Get single property
print (P4DProps.Value['string1'])
print (P4DProps.Value['string2'])
print (P4DProps.Value['string3'])

# Change one of the properties
P4DProps.Value['string1'] = "Changed Text 1"
P4DProps.Value['string2'] = "Changed Text 2"
P4DProps.Value['string3'] = "Changed Text 3"
# By reassigning the same object, we force the OnChange event
# That will update the Delphi controls
P4DProps.Value = P4DProps.Value
