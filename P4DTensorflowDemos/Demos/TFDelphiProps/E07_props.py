# Display the Properties content
print (P4DProps)
# Get single property
print (P4DProps.Value['string1'])
print (P4DProps.Value['integer1'])
print (P4DProps.Value['radiogroup1'])
print (P4DProps.Value['checkboxgroup1'])
print (P4DProps.Value['filename1'])
print (P4DProps.Value['date1'])

# Put single property
P4DProps.Value['string1'] = "Changed Text XYZ"
P4DProps.Value['integer1'] = 9999
P4DProps.Value['radiogroup1'] = 3
P4DProps.Value['checkboxgroup1'] = [1,1,1,1]
P4DProps.Value['filename1'] = "NewFilenameXYZ"
P4DProps.Value['date1'] = ["01.01.2017","31.12.2099"]

# By reassigning the same object, we force the OnChange event
# That will update the Delphi controls
P4DProps.Value = P4DProps.Value
