# Display the Properties content
print (P4DProps)
# Get single property
print (P4DProps.Value['checkboxgroup1'])
print (P4DProps.Value['checkboxgroup2'])

# Put single property
P4DProps.Value['checkboxgroup1'] = [1,1]
P4DProps.Value['checkboxgroup2'] = [0,0,0,0]

# By reassigning the same object, we force the OnChange event
# That will update the Delphi controls
P4DProps.Value = P4DProps.Value
