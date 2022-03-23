function Visualize_ant_array_orientation(num_ant, array_rotation, ant_spacing, carrier_freq)
    %Visualize_ant_array_orientation: Visualize the BS antenna array orientation

    % num_ant --> Number of the UPA antenna array on the x,y,z-axes
    % array_rotation ---> Rotation angles [gamma, beta, alpha] in degrees
    % carrier_freq ---> Carrier frequency in Hz
    % ant_spacing ---> Antenna array element spacing as a ratio of the wavelength

    %% Calculations
    Ds = ant_spacing*(physconst('LightSpeed')/carrier_freq);
    Mx = num_ant(1);
    My = num_ant(2);
    Mz = num_ant(3);
    Alpha = array_rotation(3);
    Beta = array_rotation(2);
    Gamma = array_rotation(1);

    Ax = linspace(0,(Mx-1)*Ds,Mx);
    Ay = linspace(0,(My-1)*Ds,My);
    Az = linspace(0,(Mz-1)*Ds,Mz);
    [AY, AX, AZ] = meshgrid(Ay,Ax,Az);
    AY = AY(:);
    AX = AX(:);
    AZ = AZ(:);

    % Apply rotations
    A = [AX AY AZ].';
    Rz = rotz(Alpha)*A;
    Rzy = roty(Beta)*Rz;
    Rzyx = rotx(Gamma)*Rzy;
    Rzyx = Rzyx.';

    %% 3D plot
    %set(0,'DefaultFigureWindowStyle','docked')

    Sc = 1e3; %Axes scaling factor to represent millimeter scales
    Marker_size = 30; Curve_width = 2.5;
    Font_size = 12;
    labels_fontsize = 12;
    Legend_fontsize = 12;
    Marker_style = 's<o>^v*x+dph';
    Line_style = cell(4,1);
    Line_style{1}='-';Line_style{2}='-.';Line_style{3}=':';Line_style{4}='--';
    Color = [
        '#0072BD'; %blue
        '#A2142F'; %red
        '#007F00'; %green
        '#7E2F8E'; %purple
        '#D95319'; %orange
        '#4DBEEE'; %cyan
        '#EDB120'; %yellow
        '#888888'; %grey
        '#000000'; %black
        '#0072BD'; %blue
        '#A2142F'; %red
        ];

    Fig2 = figure('Name', 'Array1', 'units','pixels');
    hold on;
    grid on;
    box on;
    Title_string = strcat('\textbf{BS Antenna Array Orientation, $\alpha=',num2str(Alpha),'^{\circ}$, ',' $\beta=',num2str(Beta),'^{\circ}$, ',' $\gamma=',num2str(Gamma),'^{\circ}$','}');
    title(Title_string,'fontsize',labels_fontsize,'interpreter','latex')
    xlabel('\textbf{X axis (mm)}','fontsize',labels_fontsize,'interpreter','latex')
    ylabel('\textbf{Y axis (mm)}','fontsize',labels_fontsize,'interpreter','latex')
    zlabel('\textbf{Z axis (mm)}','fontsize',labels_fontsize,'interpreter','latex')
    set(gca,'FontSize',Font_size)
    if ishandle(Fig2)
        set(0, 'CurrentFigure', Fig2)
        hold on;
        grid on;
        scatter3(AX*Sc,AY*Sc,AZ*Sc,Marker_size,[0 0.4470 0.7410],'o','filled')
        scatter3(Rzyx(:,1)*Sc,Rzyx(:,2)*Sc,Rzyx(:,3)*Sc,Marker_size,[0.6350 0.0780 0.1840],'o','filled')
        plotcube((max(A*Sc,[],2).'),[0 0 0],0.1,[0 0.4470 0.7410])
        view([150 45])

        lgd = legend({'Before the rotations','After the rotations'},'Location','northwest','Interpreter','latex','FontSize',Legend_fontsize);
        title(lgd,'BS Antenna Array Orientation')
        legend show
        set(gca,'XMinorTick','on','YMinorTick','on')
    end
    drawnow
    hold off
    rotate3d on

end

