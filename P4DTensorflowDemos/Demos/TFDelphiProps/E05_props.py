# Display the Properties content
print (P4DProps)
# Get single property
print (P4DProps.Value['filename1'])
print (P4DProps.Value['filename2'])

# Change one of the properties
P4DProps.Value['filename1'] = "NewFilename1"
P4DProps.Value['filename2'] = "NewFilename2"
# By reassigning the same object, we force the OnChange event
# That will update the Delphi controls
P4DProps.Value = P4DProps.Value
