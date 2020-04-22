function im_thre = matchedFilter(image,plot)
    %% Ԥ����
    % ��ȡ��ɫͨ��
    [~, g, ~] = imsplit(image);
    
    % ��ģ����
    im_mask = g > 40; 
    im_mask = imerode(im_mask, strel('disk',5));
    
    % CLAHE
    bw = adapthisteq(g);

    % ��̬ѧ����
    SE = strel('disk',5);
    %SE = strel('square',5);
    marker = imerode(bw,SE);
    mask = bw;
    mid = imreconstruct(marker,mask);
   
    % ��ñ�任
    mid = imbothat(mid, SE);
    %mid = 255 - mid;
    mid = adapthisteq(mid);
    
    %% Matched Filtering
    img = im2double(mid);
    s = 1.5; %sigma
    L = 7;
    theta = 0:15:360; %different rotations
    out = zeros(size(img));
    m = max(ceil(3*s),(L-1)/2);
    [x,y] = meshgrid(-m:m,-m:m); % non-rotated coordinate system, contains (0,0)
    for t = theta
       t = t / 180 * pi;        % angle in radian
       u = cos(t)*x - sin(t)*y; % rotated coordinate system
       v = sin(t)*x + cos(t)*y; % rotated coordinate system
       N = (abs(u) <= 3*s) & (abs(v) <= L/2); % domain
       k = exp(-u.^2/(2*s.^2)); % kernel
       k = k - mean(k(N));
       k(~N) = 0;               % set kernel outside of domain to 0
       res = conv2(img,k,'same');
       out = max(out,res);
    end
    out = out/max(out(:));
    level = graythresh(out);
    im_thre = imbinarize(out,level) & im_mask;
    if plot == true
        figure();
        subplot(1,5,1);imshow(g,[]);title('��ɫͨ��');
        subplot(1,5,2);imshow(bw,[]);title('CLAHE��ǿ');
        subplot(1,5,3);imshow(mid,[]);title('��̬ѧ�����붥ñ�任');
        subplot(1,5,4);imshow(out,[]);title('�˲����');
        subplot(1,5,5);imshow(im_thre,[]);title('��ֵ������');
    end
end