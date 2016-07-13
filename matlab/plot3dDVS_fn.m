% funcion que hace el plot para el DVS en 3D

function [] = plot3dDVS_fn(ON_events,OFF_events)

N = str2num(getenv('N')); 
M = str2num(getenv('M')); 
PATH_folder_images = getenv('PATH_folder_images');

cd(PATH_folder_images)

i = 0;
X = 0:2*N-1;
Y = 0:2*M-1;
z  = zeros(2*M,2*N);
scaleTime=1e3;
len_ON_events = length(ON_events);

struct_limsX = {[]};
struct_limsY = {[]};
for x=1:2*N
    
    if rem(x,2) == 1
        struct_limsX{x} = '';
    else
        struct_limsX{x} = num2str(x/2 - 1);
    end
end

for x=1:2*M
    
    if rem(x,2) == 1
        struct_limsY{x} = '';
    else
        struct_limsY{x} = num2str(x/2 - 1);
    end
end

if ( len_ON_events > 1)
    fig_ON = figure('Visible','off','units','normalized');%,'outerposition',[0 0 1 1]);
    colormap(fig_ON,'gray')
    while i < len_ON_events
        
        vec_time_pix = ON_events{i+1};
        t = vec_time_pix(1);
        pixel = vec_time_pix(2);
        row = fix(pixel/N);
        col = rem(pixel,N);
        y1  = row+1;
        y2  = y1+1;
        x1  = col+1;
        x2  = x1+1;
        z(:,:) = NaN; % Avoid that Matlab create lines no desired
        z([y1 y2],[x1 x2]) = scaleTime*t;
        surf(X,Y,z)
        hold on
        grid on
        i = i+1;

    end

    % adjusting apperance
    set(gca,'xtick',X);
    set(gca,'ytick',Y);
    set(gca,'Ydir','reverse')
    xlim([0 N])
    ylim([0 M])
    xlabel('COLUMNS')
    ylabel('ROWS')
    zlabel('Time ms')
    name_title = 'ON EVENTS MODEL';
    name_fig = 'ON_events_3D_Model';
    title(name_title)
    set(fig_ON,'PaperPositionMode','auto')
    print('-depsc2','DVS_ON_Model.eps')
    print('-dpng','DVS_ON_Model.png')
    saveas(gcf,'DVS_ON_Model','fig');
end


len_OFF_events = length(OFF_events);
z  = zeros(2*M,2*N);
i = 0;

if ( len_OFF_events >1)
    fig_OFF = figure('Visible','off');
    colormap(fig_OFF,'gray')
    while i < len_OFF_events

        vec_time_pix = OFF_events{i+1};
        t = vec_time_pix(1);
        pixel = vec_time_pix(2);
        row = fix(pixel/N);
        col = rem(pixel,N);
        y1  = row+1;
        y2  = y1+1;
        x1  = col+1;
        x2  = x1+1;
        z(:,:) = NaN; % Avoid that Matlab create lines no desired
        z([y1 y2],[x1 x2]) = scaleTime*t;
        surf(X,Y,z)
        hold on
        grid on
        i = i+1;

    end

    % adjusting apperance
    set(gca,'Ydir','reverse')
    set(gca,'xtick',X);
    set(gca,'ytick',Y);
    xlim([0 N])
    ylim([0 M])
    xlabel('COLUMNS')
    ylabel('ROWS')
    zlabel('Time ms')
    name_title = 'OFF EVENTS MODEL';
    title(name_title)
    set(fig_OFF,'PaperPositionMode','auto')
    print('-depsc2','DVS_OFF_Model.eps')
    print('-dpng','DVS_OFF_Model.png')
    saveas(gcf,'DVS_OFF_Model','fig');
end