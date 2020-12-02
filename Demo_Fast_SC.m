
% RF sensing example
% 
% Andy Nicholson

% Adapted from ::
% This script demonstrates the use of the Fast Spectral Correlation code
% "Fast_SC.m" on a synthetic cyclostationary signal.
% https://au.mathworks.com/matlabcentral/fileexchange/60561-fast_sc-x-nw-alpha_max-fs-opt
% Jerome Antoni (2020). Fast_SC(x,Nw,alpha_max,Fs,opt) (https://www.mathworks.com/matlabcentral/fileexchange/60561-fast_sc-x-nw-alpha_max-fs-opt), MATLAB Central File Exchange. Retrieved September 21, 2020.


clear all
close all

% Synthesis of an elementary cyclostationary signal
% =================================================


% for 1. RANDOM signal

% Fs = 1e3;               % sampling frequency (in Hz)
% L = 1e5;                % signal length (number of samples)
% f0 = .01*Fs;            % cycle frequency (in Hz)

%
% 1. RANDOM SIGNAL
%
% x = randn(L,1);

% filtration by a resonance
% a = [1 -2*cos(2*pi*.2)*.9 .9^2];
% x = filter(1,a,x);

% periodic amplitude modulation
% x = x.*(1 + sin(2*pi*(0:L-1)'*f0/Fs));

% addition of white noise (SNR = 0dB)
% x = x + std(x)*randn(L,1);


% 2. RF SIGNALS


gain = 2;
sample_rate = 2.048e6;

%centre_freqs = [ 87.8000   90.9000   94.1000   95.7000   96.5000   97.3000   98.1000   98.9000  105.3000  106.9000 ];

%centre_freqs = [ 87.7 87.8000 87.9 ];

centre_freqs = [ 98.9 99.35 105.3  ];

% Scanning loop.
for freq_index=1: length(centre_freqs)



    %we want num_samples to be power of 2.
    %
    num_samples_exponent = 19;

    %
    % Implied parameters
    %
    observe_time = 2^num_samples_exponent / sample_rate;

    num_samples = 2^num_samples_exponent;


    Fs = sample_rate;
    L = num_samples;

    % check if previous tce objects existed. if so clear them
    if ~isempty(who('tcp_obj'))
        fclose(tcp_obj);
        delete(tcp_obj);
        clear tcp_obj;
    end

    % construct tcp objects
    tcp_obj = tcpip('192.168.0.14', 1234);

    % input buffer size, and size of flushing read to do.
    inputBuff_size = 2 * 2 * num_samples;

    set(tcp_obj, 'InputBufferSize', inputBuff_size);
    set(tcp_obj, 'Timeout', 60);

    try
        fopen(tcp_obj);
    catch aException
        disp(' TCPIP open failed, trying again ');
    end


    if strcmp(tcp_obj.Status,'closed')
        disp('TCPIP channel not open. Starting again.');
        tcp_failed = 1;

    end

    % set gain, sampling rate, and centre freq
    set_gain_tcp(tcp_obj, gain*10); %be careful, in rtl_sdr the 10x is done inside C program, but in rtl_tcp the 10x has to be done here.
    set_rate_tcp(tcp_obj, sample_rate);
    freq_sampling = centre_freqs(freq_index) * 1e6;
    set_freq_tcp(tcp_obj, freq_sampling);

    % read and discard to flush
    % disp('Starting flushing');

    fread(tcp_obj, inputBuff_size, 'uint8');

    % capture samples of all frequencies firstly!

    disp(['Start scanning '  num2str(freq_sampling)]);
    s_all = fread(tcp_obj, 2*num_samples, 'uint8');

    if size(s_all)-(2*num_samples) ~= 0
        disp('Didnt get all samples');
        tcp_failed = 1;

    end

    fclose(tcp_obj);
    delete(tcp_obj);
    clear tcp_obj;

    % Get back a IQ signal with DC removed. complex number constructed.
    x = raw2iq( double( s_all ) );  

    %figure
    %plot((0:L-1)/Fs,x),title('Synthetic cyclostationary signal')
    %xlabel('time (s)')


    % Fast Spectral Correlation
    % =========================
    % Analysis parameters to be fixed by the user
    Nw = 2^8;               % window length (number of samples)    
    
    f0 = sample_rate/100;
    alpha_max = 4*f0;       % maximum cyclic frequency to scan (in Hz)
    % (should cover the cyclic frequency range of interest)
    opt.coh = 0;            % compute sepctral coherence? (yes=1, no=0)


    [S,alpha,f,Nv] = Fast_SC(x,Nw,alpha_max,Fs,opt);


    figure,subplot(211)
    imagesc(alpha(2:end),f,abs(S(:,2:end))),axis xy,colorbar('Location','north')
    if opt.coh == 0,title('Spectral Correlation'),else,title('Spectral Coherence'),end
    xlabel('cyclic frequency \alpha (Hz)'),ylabel('f (Hz)'),
    xlim([0 alpha_max])

    
    yyy=mean(abs(S(:,2:end)));
    subplot(212),plot(alpha(2:end),yyy,'k'),xlim([0 alpha_max])
    title(['Enhanced envelope spectrum ' num2str(freq_sampling)]);
    xlabel('cyclic frequency \alpha (Hz)')

    
    %
    % Feature detection. Find peaks
    %
    
    [p,f] = findpeaks( yyy , alpha(2:end) , 'MinPeakHeight', mean(yyy)*8 );
    
    disp([' Found ' num2str(length(p)) '  Mean of spectrum is ' num2str(mean(yyy))]);
    %disp(f);

    pilots = find( f > 18.9e3 & f < 19.1e3);
    for kk=1:length(pilots)
        disp([' Pilot frequency ' num2str(f(pilots(kk))) ]);
    end
    
    % It may happen that the resolution of the computer screen is not enough to
    % display all the details in the spectral correlation; in this case, a solution
    % is to decrease the cycli spectral resolution by smoothing.

    screen_resolution = 1080;       % number of vertical lines
    Na = length(alpha);
    N = round(Na/screen_resolution);
    w = hamming(2*N+1);
    if N > 1
        Smooth = zeros(Nw/2+1,Na);
        for k = 1:Nw/2+1
            Smooth(k,:) = conv(abs([0 S(k,2:end)]),w,'same');
        end

        figure,
        imagesc(alpha(2:end),f,Smooth),axis xy,colorbar('Location','north')
        if opt.coh == 0,title('Smoothed spectral Correlation'),else,title('Smoothed spectral Coherence'),end
        xlabel('cyclic frequency \alpha (Hz)'),ylabel('f (Hz)'),
        xlim([0 alpha_max])
    end


end
