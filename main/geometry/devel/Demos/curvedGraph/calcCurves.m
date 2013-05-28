%DEMOCURVEDGRAPH compute curved boundary graph


%% Startup image

% load images
img = imread('imageSeg.tif');
figure; 
imshow(img);


%% Fit polynomials

% polynomial degree
deg = 2;

% compute coefficient for each curve that is boundary between two regions
coefs = polynomialCurveSetFit(~img, deg);

% prepare display
figure;
imshow(img)
hold on;

% draw curves as overlays
for i = 1:length(coefs)
    h = drawPolynomialCurve([0 1], coefs{i});
    set(h, 'linewidth', 2, 'color', 'b');
end

% draw only curves
figure; 
imshow(ones(size(img)));
hold on;
for i = 1:length(coefs)
    h = drawPolynomialCurve([0 1], coefs{i});
    set(h, 'linewidth', 2, 'color', 'b');
end
