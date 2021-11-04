


function M = image_add_noise(I, noise_level)
% Add noise to the image amplitude signal...

% This is fairly rudimentary and deals with the image domain only (i.e.
% not k-space)...

    if noise_level == 0, M = I; return; end
    
    y_dim = size(I,1);
    x_dim = size(I,2);

    M = zeros(y_dim, x_dim);
    
    % Set SD of normal distribution to be level of noise input...
    sigma = noise_level;

    for c = 1:x_dim
        for r = 1:y_dim
            
            % Noise is 2-D Gaussian distributed...
            N = complex(randn(1,1), randn(1,1)) * sigma;

            % Complex addition of signal and noise...
            A = complex(I(r,c), 0);
            C = A + N;

            % Take magnitude and return....
            M(r,c) = sqrt(real(C).^2 + imag(C).^2);
    
        end
    end
    
end
