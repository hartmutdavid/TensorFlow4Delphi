# Display the Properties content
print (P4DProps)
# Get single property
print (P4DProps.Value['date1'])
print (P4DProps.Value['date2'])
print (P4DProps.Value['date3'])

# Put single property
P4DProps.Value['date1'] = ["01.01.2017",""]
P4DProps.Value['date2'] = ["","31.12.2017"]
P4DProps.Value['date3'] = ["01.01.2017","31.12.2017"]

# By reassigning the same object, we force the OnChange event
# That will update the Delphi controls
P4DProps.Value = P4DProps.Value
