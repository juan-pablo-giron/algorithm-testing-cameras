%a=zeros(200,300);
%a=randi([0 255],200,200);
%a(:,:)=190;

Nmax=255;
pixel = 0;
N = 1000;
M = 1000;
size_pixel = 50  ; % count how pixel columns is taken 
quant_pixels = (N/size_pixel)*(M/size_pixel);
row_total=M/size_pixel;
col_total=N/size_pixel;
a=zeros(M,N);
tmp=zeros(size_pixel,size_pixel);
grad = (Nmax/quant_pixels);
grad_i = 0;
init = 1;
cmap = colormap('gray');
%imwrite(uint8(a),'grayscalespallete.gif','DelayTime',0.1)
while (pixel < quant_pixels)

    row = fix(pixel/col_total);
    col = mod(pixel,col_total);
    r_1 = size_pixel*row+1;
    r_2 = size_pixel*(row+1);
    c_1 = size_pixel*col+1;
    c_2 = size_pixel*(col+1);
    %a([r_1:r_2],[c_1:c_2]) = grad_i;
    tmp(:,:)=grad_i;    
    %imwrite(uint8(tmp),'grayscalespallete.gif','DelayTime',0.001,'WriteMode','append');
    if pixel == 0;
        colormap('gray');
   	    imwrite( uint8(tmp),'filename.gif','gif','LoopCount',0,'DelayTime',0.01);
        %colormap(gray);
    else 	
        colormap('gray'); 	
        imwrite(uint8(tmp),'filename.gif','gif','WriteMode','append','DelayTime',0.01); 	
        %colormap(gray);
    end
    grad_i = grad_i + grad;    
    
    
    pixel = pixel + 1;
end
a;
%imwrite(uint8(a),'grayscalespallete.gif','DelayTime',0.1)