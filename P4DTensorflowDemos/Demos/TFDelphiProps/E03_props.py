# Display the Properties content
print (P4DProps)
# Get single property
print (P4DProps.Value['radiogroup1'])
print (P4DProps.Value['radiogroup2'])

# Change one of the properties
P4DProps.Value['radiogroup1'] = 0
P4DProps.Value['radiogroup2'] = 3
# By reassigning the same object, we force the OnChange event
# That will update the Delphi controls
P4DProps.Value = P4DProps.Value
