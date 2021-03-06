%Name:          FarFieldCalculations
%Description:   This program calculate the far-field pattern of a swarm of drones
%               carrying scatters. 
%--------------------------------------------------------------------------
%INPUT:         Excel Values, User-Specified, or Default values to obtain:
%
%               FREQUENCY (Operating frequency in [Hz])
%               BEAM_DIRECTION (Initial direction of beam in [degrees])
%               BEAM_DIRECTION_2 (Second beam direction in [degrees])
%               NUM_DRONES = input('Input the number of drones within swarm: ')
%               SWARM_RADIUS = input('Input the swarm radius: ')
%               MAX_ERROR_ALLOWED input('Input the max allowed position error: ')
%               Kn = input('Specify kn''s coefficient: ')
%--------------------------------------------------------------------------               
%OUTPUT:        Far field Patterns and interesting related plots
%--------------------------------------------------------------------------
clc
clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% BEGIN FORM REQUEST AND RETURN VALUES  %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set true to generate form, else set to false.
FormRead = "false";

%Check GenerateForm.m for a list of defaults when form is not generated.
[ExcelRead, Defaults, Formation, Center, Offset, Rotate] = GenerateForm(FormRead);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Load in Excel Sheet Data  %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(ExcelRead == "Yes")
    %TO DO: Implement Excel Read.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%  VARIABLES  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (Center == "No")
        NUM_CROSS = 4;
        NUM_PENT = 5;
    else
        NUM_CROSS = 5;
        NUM_PENT = 6;
    end
if(Defaults == "Yes")
    % Users may also change these variables for quick modifications to the
    % simulation.
    BEAM_DIRECTION = 45;        
    BEAM_DIRECTION_2 = 270;     % Second beam direction in degrees
    FREQUENCY = 1.2 * 10^(9);   % Frequency in Hz
    MAX_ERROR_ALLOWED = .01;    % Used to show effects of misplacements in xy
    SWARM_RADIUS = (6.25/100);       % Position of drones in cross pattern
    
    Kn=0;  
else
    BEAM_DIRECTION = input("Input the desired beam direction");
    BEAM_DIRECTION_2 = input("Input a redirected beam direction");
    FREQUENCY = input("Input the operating frequency");
    MAX_ERROR_ALLOWED = input("Input the maximum allowed error in [m]");
    SWARM_RADIUS = input("Input the radius of the swarm in [m]");
    Kn = input("Specify a Kn Value");
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%  Generate Drone Formations  %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[crossXY,pentXY] = GenerateSwarms(Formation,Center,SWARM_RADIUS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Constants  %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c = 2.9992458*(10.^8); u0 = 4*pi*(10.^-7); e0 = 1/((c.^2)*(u0));
w = 2 * pi * FREQUENCY; k0 = w*sqrt(u0*e0); center_of_swarm = [25,0,100];
xs = center_of_swarm(1); ys = center_of_swarm(2); zs = center_of_swarm(3);
rs = norm(center_of_swarm); theta_s = acos(zs/rs);
phi_s = atan2(ys,xs); phi = 0:0.01:2*pi;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%  Implementation of Equation (30)  %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[crossZ,pentZ] = GenerateZ(Formation,...
                            crossXY,pentXY,...
                            BEAM_DIRECTION,...
                            FREQUENCY,...
                            NUM_CROSS,NUM_PENT);
                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  Generate rotating swarm positions  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TODO: Fix implementation for "Both"
[crossXY_rotate,pentXY_rotate] = RotateSwarm(crossXY,pentXY,...
                                                crossZ,pentZ,...
                                                SWARM_RADIUS,...
                                                Formation,Center,...
                                                NUM_CROSS,NUM_PENT); 
                                            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%  Generate rotating Far Field  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%YEET%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
[cross_rot_field,pent_rot_field] = RotateField(crossXY_rotate,...
                                                pentXY_rotate,...
                                                Formation,...
                                                BEAM_DIRECTION,...
                                                FREQUENCY,...
                                                NUM_CROSS,NUM_PENT); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  Calculation of far field graphs  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[crossField,pentField] = GenerateFarFields(Formation,...
                                            crossXY,pentXY,...
                                            crossZ,pentZ,...
                                            FREQUENCY,...
                                            NUM_CROSS,NUM_PENT);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%  Recalculation using new theta  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate new z positions for the redirected beam.
[crossZ2,pentZ2] = GenerateZ(Formation,...
                                crossXY,pentXY,...
                                BEAM_DIRECTION_2,...
                                FREQUENCY,...
                                NUM_CROSS,NUM_PENT);
% Calculation of redirected far field graph
[crossField2,pentField2] = GenerateFarFields(Formation,...
                                            crossXY,pentXY,...
                                            crossZ2,pentZ2,...
                                            FREQUENCY,...
                                            NUM_CROSS,NUM_PENT);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  Calculation of Jitter far field graphs  %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[cross_offset_pos, cross_offset_field,...
    pent_offset_pos,pent_offset_field] = ...
                                    GenerateOffsets(Offset,...
                                                    crossXY, pentXY,...
                                                    crossZ,pentZ,...
                                                    MAX_ERROR_ALLOWED,...
                                                    FREQUENCY,...
                                                    NUM_CROSS,NUM_PENT);
                                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%  GRAPHING SECTION  %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%  Plot Initial and Recaculated FarField  %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(Formation == "Cross")
norm = max(crossField);     % Get max val to normalize
figure(1);
tiledlayout(1,1)
nexttile;
polarplot(phi, abs(crossField)/abs(norm));  
title('Cross Far Field Plot')
rlim([0 1]);
title('Variation of Beam Direction')
hold on
norm2 = max(crossField2);
polarplot(phi, abs(crossField2)/abs(norm2), '--' );
hold off
end

if(Formation == "Pentagon")
norm = max(pentField);     % Get max val to normalize
figure(1);
tiledlayout(1,1)
nexttile;
polarplot(phi, abs(pentField)/abs(norm));  
title('Pentagon Far Field Plot')
rlim([0 1]);
title('Variation of Beam Direction')
hold on
norm2 = max(pentField2);
polarplot(phi, abs(pentField2)/abs(norm2), '--' );
hold off
end

if(Formation == "Both")
norm = max(crossField);     % Get max val to normalize
figure(1);
tiledlayout(1,2)

nexttile;
polarplot(phi, abs(crossField)/abs(norm));  
title('Cross Far Field Plot')
rlim([0 1]);
title('Variation of Beam Direction')
hold on
norm2 = max(crossField2);
polarplot(phi, abs(crossField2)/abs(norm2), '--' );
hold off

nexttile;
polarplot(phi, abs(pentField)/abs(norm));  
title('Pentagon Far Field Plot')
rlim([0 1]);
title('Variation of Beam Direction')
hold on
norm2 = max(pentField2);
polarplot(phi, abs(pentField2)/abs(norm2), '--' );
hold off
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%  Creating Offset Graphs  %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This graph depicts the correct xy positions vs the incorrectly
%   placed antennas in xy plane and the resulting far field 
%   patterns.

if(Offset == "Cross") 
    figure(2);
    tiledlayout(2,2)
    
    nexttile; %Top-Down View
    scatter(crossXY(:,1), crossXY(:,2),'filled');
    title('Correct vs Misplaced: Top-Down View')
    xlabel('X Axis')
    ylabel('Y Axis')
    hold on
    scatter(cross_offset_pos(:,1), cross_offset_pos(:,2));
    hold off
    
    nexttile; % Side View
    scatter(crossXY(:,1), crossZ(:),'filled');
    title('Correct vs Misplaced: Side View')
    xlabel('X Axis')
    ylabel('Z Axis')
    hold on
    scatter(cross_offset_pos(:,1), cross_offset_pos(:,3));
    hold off
    
    nexttile; % 3D View
    plot3(cross_offset_pos(:,1), cross_offset_pos(:,2), cross_offset_pos(:,3), 'o');
    title('3D Position Plot')
    grid on
    hold on
    plot3(crossXY(:,1), crossXY(:,2),crossZ(:), '*');
    hold off
end

if(Offset == "Pentagon") 
    figure(2);
    tiledlayout(2,2)
    
    nexttile; %Top-Down View
    scatter(pentXY(:,1), pentXY(:,2),'filled');
    title('Correct vs Misplaced: Top-Down View')
    hold on
    scatter(pent_offset_pos(:,1), pent_offset_pos(:,2));
    xlabel('X Axis')
    ylabel('Y Axis')
    hold off  
    
    nexttile; % Side View
    scatter(pentXY(:,1), pentZ(:),'filled');
    title('Correct vs Misplaced: Side View')
    xlabel('X Axis')
    ylabel('Z Axis')
    hold on
    scatter(pent_offset_pos(:,1), pent_offset_pos(:,3));
    hold off
    
    nexttile; % 3D View
    plot3(pent_offset_pos(:,1), pent_offset_pos(:,2), pent_offset_pos(:,3), 'o');
    title('3D Position Plot')
    grid on
    hold on
    plot3(pentXY(:,1), pentXY(:,2),pentZ(:), '*');
    hold off
end

if(Offset == "Both")
    % TO DO
end
%-----------------Far Field Plots-------------------------
if(Offset == "Cross") 
nexttile;
polarplot(phi, abs(crossField)/abs(norm));
rlim([0 1]);
title('Effect on Far Field Pattern')
hold on
polarplot(phi, abs(cross_offset_field)/abs(norm), '--' );
hold off
end

if(Offset == "Pentagon") 
nexttile;
polarplot(phi, abs(pentField)/abs(norm));
rlim([0 1]);
title('Effect on Far Field Pattern')
hold on
polarplot(phi, abs(pent_offset_field)/abs(norm), '--' );
hold off
end

if(Offset == "Both")
    % TO DO
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%  Plot Rotating Swarm Positions  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
figure(3);

if(Formation == "Cross")
    tiledlayout(NUM_CROSS,1)
    for i = 1:NUM_CROSS
        nexttile
        scatter(crossXY_rotate(i,:,1),crossXY_rotate(i,:,2),[],(1:size(crossXY_rotate,2)).','.');
    end
    colormap(jet) %From blue to red
    title('Rotating Cross Swarm X & Y Values')
end
if(Formation == "Pentagon")
    tiledlayout(NUM_PENT,1)
    for i = 1:NUM_PENT
        nexttile
        scatter(pentXY_rotate(i,:,1),pentXY_rotate(i,:,2),[],(1:size(pentXY_rotate,2)).','.');
    end
    colormap(jet) %From blue to red
    title('Rotating Pentagon Swarm X & Y Values')
end

if(Formation == "Both")
    tiledlayout(NUM_CROSS,1)
    for i = 1:NUM_CROSS
        nexttile
        scatter(crossXY_rotate(i,:,1),crossXY_rotate(i,:,2),[],(1:size(crossXY_rotate,2)).','.');
    end
    colormap(jet) %From blue to red
    title('Rotating Cross Swarm X & Y Values')
    figure(4);
    tiledlayout(NUM_PENT,1)
    if(Formation == "Pentagon")
        for i = 1:NUM_PENT
            nexttile
            scatter(pentXY_rotate(i,:,1),pentXY_rotate(i,:,2),[],(1:size(pentXY_rotate,2)).','.');
        end
    end
    colormap(jet) %From blue to red
    title('Rotating Pentagon Swarm X & Y Values')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%  Graphing Rotating Far Field  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4);
inc = pi/180;
phi = inc:inc:2*pi; % phi is 360 degrees at intervals of 1 degree
if(Formation == "Cross")
    normRotate = max(cross_rot_field);     % Get max val to normalize
    polarplot(phi, abs(cross_rot_field)/abs(normRotate));
    title('Rotating swarm FarField')
end
if(Formation == "Pentagon")
    normRotate = max(pent_rot_field);     % Get max val to normalize
    polarplot(phi, abs(pent_rot_field)/abs(normRotate));
    title('Rotating swarm FarField')
end

if(Formation == "Both")
    figure(5);
    %To do
end


