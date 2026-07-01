function [threshold, threshold_xmin, threshold_xmax, offset] =  ROI_creation_ET(name, threshold, files, idx, files_exp)

% Threshold contains the separation between eyes and mouth (y axis) for each
% of the 4 blocks, it is selected based on the time data, on the blue line
% (y)

% Threshold_xmin xmax contain the left and right limits of the 'cage' that
% contains valid points


threshold_xmin = [-0.5, -0.5, -0.5, -0.5];
threshold_xmax = [2, 2, 2, 2];
offset = 2;
if strcmp(char(name), 'NLP01')
    threshold = [-7.5, 1.3, nan, nan];
    threshold_xmin = [-2, -0.5, nan, nan];
    threshold_xmax = [2, 1.5, nan, nan];
    offset = 4;
elseif strcmp(char(name), 'NLP02')
    threshold = [nan, nan, nan, nan];
elseif strcmp(char(name), 'NLP03')
    threshold = [0.96, -3.5, -3.5, -2.3];
    threshold_xmin = [-1, -1.2, -1, -1];
    threshold_xmax = [1, 1, 1, 1];
elseif strcmp(char(name), 'NLP04') 
    threshold = [-2.5, -2.9, 0.6, -2.3];
    threshold_xmin = [-1.5, -1.5, -0.5, -0.5];
    threshold_xmax = [0.5, 0.5, 1, 1];
elseif strcmp(char(name), 'NLP05') 
    threshold = [-2.3, 0.7, nan, nan];
elseif strcmp(char(name), 'NLP06')
    threshold = [-2.7, -2.2, 2-4, -2];
    threshold_xmin = [-1, -1, -1, -1];
    threshold_xmax = [1, 1, 1, 1];
elseif strcmp(char(name), 'NLP07') 
    threshold = [-1.8, -1.5, nan, nan];
    threshold_xmin = [-0.5, -1, -1, -0.5];
    threshold_xmax = [0.5, 1, 1.5, 0.5];
elseif strcmp(char(name), 'NLP08')
    threshold = [0.3, 0, 1.5, 0];
    threshold_xmin = [0.5, 1, 0.5, -0.5];
    threshold_xmax = [1.5, 2.5, 2, 1];
elseif strcmp(char(name), 'NLP09') 
    threshold = [1, -1, nan, nan];
elseif strcmp(char(name), 'NLP10') 
    threshold = [0.8, -2, -2, nan];
    threshold_xmin = [1.5, -0.5, -0.7, nan];
    threshold_xmax = [2.5, 1.5, 0.7, nan];
elseif strcmp(char(name), 'NLP11') 
    threshold = [-2.2, -2.2, -2.2, -2.2];
    threshold_xmin = [-0.5, -0.5, -0.5, -0.5];
    threshold_xmax = [1.5, 1.5, 1.5, 1.5];
elseif strcmp(char(name), 'NLP12') 
    threshold = [-1.8, nan, nan, nan];
    threshold_xmin = [-0.7, -0.7, -0.7, -0.7];
    threshold_xmax = [1, 1, 1, 1];
elseif strcmp(char(name), 'NLP13') 
    threshold = [0.95, -2.4, -2, -2];
    threshold_xmin = [0.7, 0.5, 0.3, 0.3];
    threshold_xmax = [2.2, 2.2, 2, 2];
elseif strcmp(char(name), 'NLP14') 
    threshold = [1.3, 1.3, 0.3, nan];
    threshold_xmin = [0.3, -0.5, -0.7, 0.3];
    threshold_xmax = [2.2, 1.2, 0.7, 2];
    offset = 2.2
elseif strcmp(char(name), 'NLP15') 
    threshold = [-2, -2, -2, 0.9];
    threshold_xmin = [-1.7, -1.5, -1.7, -0.7];
    threshold_xmax = [0.7, 1.5, 0.7, 1.2];
elseif strcmp(char(name), 'NLP16') 
    threshold = [-2.5, -2.6, nan, nan];
    threshold_xmin = [0, -0.5, nan, nan];
    threshold_xmax = [1.5, 1.5, nan, nan];
elseif strcmp(char(name), 'NLP17') 
    threshold = [-2.5, -2.5, -2.5, -2.5];
    threshold_xmin = [0.3, -0.5, -0.5, 0];
    threshold_xmax = [1.7, 1.3, 2, 2];
elseif strcmp(char(name), 'NLP18')
    threshold = [-2, -2, -2, -2];
elseif strcmp(char(name), 'NLP19') 
    threshold = [0, 0, nan, nan];
    threshold_xmin = [0, -1, nan, nan];
    threshold_xmax = [1.5, 0.3, nan, nan];
elseif strcmp(char(name), 'NLP20')
    threshold = [0.7, 0.7, 0.7, -2.5];
    threshold_xmin = [-0.5, -0.5, 0, -1];
    threshold_xmax = [1, 1, 1.5, 1];
elseif strcmp(char(name), 'NLP21')
    threshold = [0.95, -2.2, 0.7, -2.5];
    threshold_xmin = [-0.5, -0.5, -0.5, -0.5];
    threshold_xmax = [1, 2, 2, 2];
elseif strcmp(char(name), 'NLP22')
    threshold = [-2.1, 1.8, 0.5, 2]
    threshold_xmin = [-2.1, 0.5, -0.2, 0.5];
    threshold_xmax = [1, 2.5, 2.5, 2.5];
elseif strcmp(char(name), 'NLP23')
    threshold = [-1, -1.5, -1.5, nan]
    threshold_xmin = [0.5, -0.5, 0, nan];
    threshold_xmax = [2.5, 1.5, 2.5, nan];
elseif strcmp(char(name), 'NLP24')
    threshold = [-2, -1.5, -2.5, nan]
    threshold_xmin = [-1.25, -1.25, -1.25, nan];
    threshold_xmax = [1.25, 1.25, 1.25, nan];
elseif strcmp(char(name), 'NLP25')
    threshold = [-2, -2, -2, -2]
    threshold_xmin = [-1.25, -1.25, -1.25, -1.25];
    threshold_xmax = [1.25, 1.25, 1.25, 1.25];
elseif strcmp(char(name), 'NLP26')
    threshold = [-2, -2, -2, -2]
    threshold_xmin = [-1.25, -1.25, -1.25, -1.25];
    threshold_xmax = [1.25, 1.25, 1.25, 1.25];
elseif strcmp(char(name), 'NLP27')
    threshold = [-1.5, -1.5, -1, nan]
    threshold_xmin = [-1.25, -1.25, -2, nan];
    threshold_xmax = [1.25, 1.25, 0.5, nan];
elseif strcmp(char(name), 'NLP28')
    threshold = [-1.2, -1.8, nan, nan]
    threshold_xmin = [-1, -1, nan, nan];
    threshold_xmax = [1.5, 1.5, nan, nan];
elseif strcmp(char(name), 'NLP30')
    threshold = [-2, -1.5, 1, nan]
    threshold_xmin = [-1.25, -0.5, -0.5, nan];
    threshold_xmax = [1.25, 2, 2, nan];

elseif strcmp(char(name), 'NLP31')
    threshold = [0.5, -0.5, nan, nan]
    threshold_xmin = [-1.25, -0.5, -0.5, nan];
    threshold_xmax = [1.25, 2, 2, nan];

elseif strcmp(char(name), 'NLP32')
    threshold = [-2, -2, nan, nan]
    threshold_xmin = [-1.25, -1.25, nan, nan];
    threshold_xmax = [1.25, 1.25, nan, nan];

elseif strcmp(char(name), 'NLP33')
    threshold = [-2, -2, -1.8, -1]
    threshold_xmin = [-1.25, -1.25, -1.25, -0.5];
    threshold_xmax = [1.25, 1.25, 1.25, 2];

elseif strcmp(char(name), 'NLP34')
    threshold = [-1.8, -1.8, -0.5, nan]
    threshold_xmin = [-0.5, -1.25, -0.5, nan];
    threshold_xmax = [2, 1.25, 2, nan];

elseif strcmp(char(name), 'NLP35')
    threshold = [-2, -2, nan, nan]
    threshold_xmin = [-1.25, -1.25, nan, nan];
    threshold_xmax = [1.25, 1.25, nan, nan];

elseif strcmp(char(name), 'NLP36')
    threshold = [-2, -2, 0, nan]
    threshold_xmin = [-1, -1, -0.5, nan];
    threshold_xmax = [1.5, 1.5, 2, nan];
    
elseif strcmp(char(name), 'NLP37')
    threshold = [-2, -2, 2, nan]
    threshold_xmin = [-1.25,-1.25, -1.25, nan];
    threshold_xmax = [1.25, 1.25, 1.25, nan];

elseif strcmp(char(name), 'NLP38')
    threshold = [-1.5, -2.2, -2.2, nan]
    threshold_xmin = [-1.25,-1.25, -1.25, nan];
    threshold_xmax = [1.25, 1.25, 1.25, nan];

elseif strcmp(char(name), 'NLP39')
    threshold = [-1.5, -1.5, -1.5, nan]
    threshold_xmin = [-0.5,-0.5, -1.25, nan];
    threshold_xmax = [1.5, 1.5, 1.25, nan];


elseif strcmp(char(name), 'NLP40')
    threshold = [-2, -1.5, nan, nan]
    threshold_xmin = [-1.25,-1.25, nan, nan];
    threshold_xmax = [1.25,1.25, nan, nan];

elseif strcmp(char(name), 'NLP41')
    threshold = [-2, 1, nan, nan]
    threshold_xmin = [-0.5,-1.25, nan, nan];
    threshold_xmax = [2,1.25, nan, nan];

elseif strcmp(char(name), 'NLP42')
    threshold = [0.5, -2, nan, nan]
    threshold_xmin = [-1.5,-1.25, nan, nan];
    threshold_xmax = [1,1.25, nan, nan];

elseif strcmp(char(name), 'NLP43')
    threshold = [-1.5, -1.5, nan, nan]
    threshold_xmin = [0,-0.5, nan, nan];
    threshold_xmax = [2.5,2, nan, nan];

elseif strcmp(char(name), 'NLP45')
    threshold = [1, 0, -2, -2]
    threshold_xmin = [0,-1.25, -0.5, -1.25];
    threshold_xmax = [2.5,1.25, 2, 1.25];

elseif strcmp(char(name), 'NLP46')
    threshold = [-2, -2, -2, nan]
    threshold_xmin = [-1.25,-1.25, -1.25, nan];
    threshold_xmax = [1.25,1.25, 1.25, nan];

elseif strcmp(char(name), 'NLP47')
    threshold = [-1, -1, nan, nan]
    threshold_xmin = [-0.5,-0.5, nan, nan];
    threshold_xmax = [2,2, nan, nan];

else
    threshold_def = [-2.7, -2.2, 2-4, -2];
end

zbk = 0;
for block = 1:length(files_exp)
    data_k = readtable(files(block).name);
    exp_k = readtable(files_exp(block).name);
    idx = regexp(exp_k.msg, "7less");
    idx = find(~cellfun(@isempty, idx));
    
    participant_col = repmat(char(name), [length(data_k.device_time_stamp), 1]);
    block_col = repmat(exp_k.msg(idx), [length(data_k.device_time_stamp), 1]);
    
    T = addvars(data_k, participant_col, 'Before', 1, 'NewVariableNames', 'Participant');
    T = addvars(T, block_col, 'Before', 2, 'NewVariableNames', 'Block');
    
    if(block ==1)
        T_participant = T;
    else
        T_participant = [T_participant; T];
    end
    
    if (block == 1 ) || (block == 8) || (block == 15) || (block == 22)
        f2 = figure;;
        cnt = 0;
        zbk = zbk + 1;
    end
    
    cnt = cnt + 1;
    f2 = subplot(7, 1, cnt)
    % Plot the left gaze x points (normal y-axis) on the left y-axis
    yyaxis right
    plot(data_k.left_gaze_point_on_display_area_x, 'DisplayName', 'X ');
    %plot(data_k.left_gaze_origin_in_track_box_coordinates_x, 'DisplayName', 'X ');
    
    %ylabel(' (X)');  % Label for the left y-axis
    
    % Plot the left gaze y points (reversed y-axis) on the right y-axis
    yyaxis left
    plot(data_k.left_gaze_point_on_display_area_y, 'DisplayName', 'Y ');
    
    set(gca, 'YDir', 'reverse');  % Reverse the y-axis for the right axis
    %ylim([-5 0])
    ylabel('(Y)');  % Label for the right y-axis
    hold on;
    hold on;
    
    % Add horizontal line at y = 2
    plot(xlim, [threshold(zbk) threshold(zbk)], '-k');  % Dashed red line across the current x-axis limits
    hold on;
    plot(xlim, [threshold(zbk)-offset threshold(zbk)-1.5], '-b');  % Dashed red line across the current x-axis limits
    hold on;
    plot(xlim, [threshold(zbk)+offset threshold(zbk)+1.5], '-b');  % Dashed red line across the current x-axis limits
    
    
    if block == 1
        
        title([name ' B ' num2str(block)])
    else
        title(['B ' num2str(block)])
    end
    
end
end