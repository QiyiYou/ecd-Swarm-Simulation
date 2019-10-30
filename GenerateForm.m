function [ ExcelRead, Defaults, Formation, Center, Offset, Rotate] = GenerateForm()

yes_no_prompt = {'Yes','No'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%  Excel Form  %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
excel_prompt = {'Would you like to import data from a spreadsheet?'};

[indx,tf] = listdlg('ListSize',[400,50],...
                    'PromptString',excel_prompt,...
                    'SelectionMode','single',...
                    'ListString',yes_no_prompt);
if(indx == 1)
    ExcelRead = 'Yes';
else
    ExcelRead = 'No';
end    
if(tf == 0)
    ExcelRead = 'Yes';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  Default or User Entered Values Form  %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
specify_prompt = {'Would you like to specify values or use defaults?'};
specify_response_prompt = {'Use Default Values','Specify Values'};

[indx,tf] = listdlg('ListSize',[400,50],...
                    'PromptString',specify_prompt,...
                    'SelectionMode','single',...
                    'ListString',specify_response_prompt);
if(indx == 1)
    Defaults = 'Yes';
else
    Defaults = 'No';
end 
if(tf == 0)
    Defaults = 'Yes';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  Select Drone Configurations Form  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

formation_prompt={'Which Drone Configuration(s) would you like to plot?'};
formation_response_prompt = {'Cross','Pentagon'};

[indx,tf] = listdlg('ListSize',[400,50],...
                    'PromptString',formation_prompt,...
                    'SelectionMode','multiple',...
                    'ListString',formation_response_prompt);
if(indx == 1)
    Formation = 'Cross';
elseif(indx == 2)
    Formation = 'Pentagon';
else
    Formation = ['Cross','Pentagon'];
end 
if(tf == 0)
    Formation = 'Cross';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%  Center Antennas Form %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

center_prompt={'Would you like for an antenna to be placed in the center?'};

[indx,tf] = listdlg('ListSize',[400,50],...
                    'PromptString',center_prompt,...
                    'SelectionMode','single',...
                    'ListString',yes_no_prompt);
if(indx == 1)
    Center = 'Yes';
else
    Center = 'No';
end    
if(tf == 0)
    Center = 'Yes';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  Offset Graphs Form  %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
offset_prompt={'Which offset plots would you like to generate?'};
offset_response_prompt = {'Cross','Pentagon','Both','None'};

[indx,tf] = listdlg('ListSize',[400,50],...
                    'PromptString',offset_prompt,...
                    'SelectionMode','single',...
                    'ListString',offset_response_prompt);

if(indx == 1)
    Offset = 'Cross';
elseif(indx == 2)
    Offset = 'Pentagon';
elseif(indx == 3)
    Offset = 'Both';
else
    Offset = 'None';
end    
if(tf == 0)
    Offset = 'None';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%  Rotation Preference Form %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rotation_prompt={'Please select a rotation preference'};
rotation_response_prompt = {'Rotate the Drones', 'Rotate the Reciever'};

[indx,tf] = listdlg('ListSize',[400,50],...
                    'PromptString',rotation_prompt,...
                    'SelectionMode','single',...
                    'ListString',rotation_response_prompt);

if(indx == 1)
    Rotate = 'Drones';
else
    Rotate = 'Reciever';
end    
if(tf == 0)
    Rotate = 'Reciever';
end

end

