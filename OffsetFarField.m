%Name:          OffsetFarField Function
%Description:   This function will calculate the FarField Pattern with
%               random offset introduced to the swarm_x,y,and z values 
%               within a maximum error amount provided. 
%--------------------------------------------------------------------------
%INPUT:         swarm_xy (All drone x and y positions in the swarm)
%               swarm_z (All drone z positions in the swarm)
%               MAX_ERROR_ALLOWED (Specified in [m])
%               FREQUENCY (Operating frequency in [hz])
%               NUM_DRONES
%--------------------------------------------------------------------------               
%OUTPUT:        offset_pos (All offset x,y,and z positions in the swarm)
%               OffsetField (The Farfield Pattern of the offset swarm)
%--------------------------------------------------------------------------
function [offset_pos, OffsetField] = OffsetFarField(swarm_xy, swarm_z, MAX_ERROR_ALLOWED, FREQUENCY, NUM_DRONES)
c = 2.9992458*(10.^8);
u0 = 4*pi*(10.^-7);
e0 = 1/((c.^2)*(u0));
w = 2 * pi * FREQUENCY;
k0 = w*sqrt(u0*e0);
center_of_swarm = [25,0,100];
xs = center_of_swarm(1);
ys = center_of_swarm(2);
zs = center_of_swarm(3);
rs = norm(center_of_swarm);
theta_s = acos(zs/rs);
phi_s = atan2(ys,xs);
phi = 0:0.01:2*pi;
Kn = 0;

OffsetField = 0;
offset_pos = zeros(NUM_DRONES,3);
for i = 1:NUM_DRONES
    xp = swarm_xy(i,1) + (((rand-.5)*2) * MAX_ERROR_ALLOWED);
    yp = swarm_xy(i,2) + (((rand-.5)*2) * MAX_ERROR_ALLOWED);
    zp = swarm_z(i) + (((rand-.5)*2) * MAX_ERROR_ALLOWED);
    offset_pos(i,1) = xp;
    offset_pos(i,2) = yp;
    offset_pos(i,3) = zp;
    alt1 = -k0 * xp * sin(theta_s) * cos(phi_s);
    alt2 = alt1 - k0 * yp * sin(theta_s) * sin(phi_s);
    alt3 = alt2 - k0 * zp * cos(theta_s);
    alt4 = exp(j * alt3);
    alt5 = alt4 * exp( j * k0 * (xp * cos(phi) + yp * sin(phi) ) );
    OffsetField = OffsetField + alt5;
end
end

