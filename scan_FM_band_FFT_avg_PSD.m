
% A P Nicholson 
% 2020 

% Originally based on scripts by
% Jiao Xianjun (putaoshu@msn.com; putaoshu@gmail.com)
% See github : https://github.com/JiaoXianjun/multi-rtl-sdr-calibration

% Assume that you have installed rtl-sdr
% (http://sdr.osmocom.org/trac/wiki/rtl-sdr) and have those native utilities run correctly already.

clear all;

% Change following parameters as you need:

% Beginning of the band you are interested in
start_freq = [87e6 89e6 91e6 93e6 95e6 97e6 99e6 101e6 103e6 105e6]; % for test of FM


% End of the band you are interested in
end_freq = [89e6 91e6 93e6 95e6 97e6 99e6 101e6 103e6 105e6 107e6];


% how many loops to do
scanningLoops=length(start_freq);

gain = 2; % If this is larger than 0, the fixed gain will be set to dongles

% use high sampling rate and FIR to improve estimation accuracy
sample_rate = 2.048e6; % sampling rate of rtlsdr

%we want num_samples to be power of 2.
%
num_samples_exponent = 18;

%
% Implied parameters
%
observe_time = 2^num_samples_exponent / sample_rate;

num_samples = 2^num_samples_exponent;


%Number of sub-blocks within a spectral band being scanned
sub_blocks_number = 2^12;


% We average the FFT over sub_blocks_number sub-blocks of the signal subband
sub_block_length = num_samples/sub_blocks_number;
 
% to construct the average FFT of entire spectrum
%
fft_avg = zeros( scanningLoops * sub_block_length , 1);


% Number of FFT entire spectrum averages.

fft_avg_number = 8;

clf;
close all;

%allocates memory
clear s_all;
s_all = uint8( zeros(2*num_samples,1) );

% Load the mappings from frqs to names
radioMap;

disp(['Number of channels is ' num2str(scanningLoops) ' ---- Number of averages across entire spectrum ' num2str(fft_avg_number) ]);
disp(['FFT size within channel ' num2str(sub_block_length) ' --- Number of samples to collect per channel ' num2str(num_samples) '--- Observing for ' num2str(observe_time) ' seconds per channel ']);
freq_step = 2.048e6 / (sub_block_length); % less step, higher resolution, narrower FIR bandwidth, slower speed

disp([ ' Freq step resolution is ' num2str(freq_step)]);

counter = 1;

%
% Thresholds of peak detection.
%
high_thresh = -50;
low_thresh = -55;
        

while 1
    % disp(['Starting averaging FFT spectrum loop number ' num2str(counter) ' out of mod ' num2str(fft_avg_number)]);
       
    % dont plot each time.
    hold on;
    r_t = [];
    
    tic;
    
    for scanL = 1: scanningLoops
        
        % disp(['Starting scanning ' num2str(scanL) ' out of ' num2str(scanningLoops)]);
        centre_freq = (end_freq(scanL) + start_freq(scanL))/2;
        tcp_failed = 0;
         
         
        % check if previous tce objects existed. if so clear them
        if ~isempty(who('tcp_obj'))
            fclose(tcp_obj);
            delete(tcp_obj);
            clear tcp_obj;
        end
        
        % construct tcp objects
        tcp_obj = tcpip('192.168.0.14', 1234);
        
        % input buffer size, and size of flushing read to do.
        inputBuff_size = 4 * 2 * num_samples;
        
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
            break;
            
        end
        
             
        % set gain, sampling rate, and centre freq
        set_gain_tcp(tcp_obj, gain*10); %be careful, in rtl_sdr the 10x is done inside C program, but in rtl_tcp the 10x has to be done here.
        set_rate_tcp(tcp_obj, sample_rate);
        set_freq_tcp(tcp_obj, centre_freq);
        
        % read and discard to flush
        % disp('Starting flushing');
        
        fread(tcp_obj, inputBuff_size, 'uint8');
        
        % capture samples of all frequencies firstly!
        
        % disp('Start scanning');
        s_all = fread(tcp_obj, 2*num_samples, 'uint8');    
            
        if size(s_all)-(2*num_samples) ~= 0
            disp('Didnt get all samples! ');
           
            tcp_failed = 1;
            break;
           
        end
        
        %disp('Scanning done!');
        
        
        % Get back a IQ signal with DC removed. complex number constructed.
        r = raw2iq( double( s_all ) );
        %         disp(['length is ' num2str(size(r)) ]);
        
        
        %
        % Add the sampled IQ data, as complex numbers, to the array
        % 
        r_t = [r_t r];
        
        %close tcp object
        fclose(tcp_obj);
        delete(tcp_obj);
        clear tcp_obj;
        
    end
    
    %     disp(' ');
    %     disp('Begin spectral analysis ...');
    
    if tcp_failed == 1
         
        continue
        
    end
    
    %
    % Process the data, as averaged FFTs, one channel at a time.
    % 
    for scanL=1:scanningLoops
        
        data_x = r_t(:,scanL);
        
        % Filtering functions
        %
        %data_x = bandpass(data_x, [ 10E3, 0.48*sample_rate  ] , sample_rate, 'Steepness',0.51);
        %data_x = lowpass(data_x, 0.49 * sample_rate , sample_rate);

        psdx = zeros( sub_block_length , 1);
        
        % X subblocks, average the FFT spectrum of this sub band.
        for sub_FFT_index = 1 : sub_blocks_number
            
            subblock_idx = ((sub_FFT_index-1) * sub_block_length) + 1 : (sub_FFT_index*sub_block_length);
            
            data_sub_x = data_x (subblock_idx); 
            
            window = hanning(length(data_sub_x));
            
            xdft = fftshift(fft(data_sub_x.*window, sub_block_length));
            psdx = ( ((1/(sample_rate*sub_block_length)) * abs(xdft).^2)  + psdx ) /2 ;
            
        end
        
        fft_avg_idx = ((scanL-1)* sub_block_length)  + 1: (scanL) * sub_block_length;
            
        % take the average
        fft_avg( fft_avg_idx ) =  ( fft_avg( fft_avg_idx ) + psdx ) / 2;

        % Null out all values smaller than -70dB.
        %       fft_avg ( fft_avg <= 10e-7) = 0;

        k_step = (end_freq(scanL)-start_freq(scanL))/(sub_block_length-1);
        freq = start_freq(scanL) : k_step : end_freq(scanL);
        
    end
    
    figure(1);
    set(gcf, 'Position', [100, 100, 1440, 900]);
    clf;
    
    k_step = (end_freq(scanningLoops) - start_freq(1))/ ( (sub_block_length * scanningLoops) - 1);
    total_freq = start_freq(1) : k_step : end_freq(scanningLoops);
    
    plot(total_freq, 10*log10(fft_avg));
    grid on;
    title('Averaged FFT');
    xlabel(' Frequency (Hz)');
    ylabel('Power (dB)');
    
    
    clear r_t;
    

    %
    % After the "fft_avg_number" scans, calculate peaks.
    %
    if (mod(counter,fft_avg_number) == 0)
        
        % gain = 0, use -20
        % gain = 2 , use -53
      
        toc
        

        fprintf('---- start ---- Time %s\n', datestr(now,'HH:MM:SS.FFF'));
        
        %
        % Feature detection. Find peaks
        %
    
    
        fft_avg_db = 10*log10(fft_avg);
        [pks, frqs] = findpeaks(fft_avg_db, total_freq, 'MinPeakHeight', high_thresh, 'MinPeakDistance', 200e3, 'MinPeakWidth', 2 * freq_step);
        
        % null out the peak powers
        fft_avg_db ( fft_avg_db > mean(pks) ) = 0;
        noise_floor_est = mean ( fft_avg_db );
        disp(['Noise floor estimate is ' num2str(noise_floor_est)]);
        
        
        frqs = round(frqs/1e6,1);
        high_thresh_size = length(frqs);
         
        disp([ num2str(high_thresh) 'db Threshold -----> Found ' num2str(high_thresh_size) ' frequency peaks ' ]);
        disp( frqs );
        
       
        
        if (high_thresh_size < 8)
            high_thresh = high_thresh - 1;
            disp('High threshold going down');
             
        end
        
        if (high_thresh_size > 10)       
            high_thresh = high_thresh + 1;
            disp('High threshold going up');
        end
            
        

        
        nameStr='';
        for jj=1:length(frqs)
           
            if radioContainer_woll.isKey(frqs(jj))
                nameStr = nameStr + sprintf("%s -- " , radioContainer_woll( frqs(jj)) );
                
            else
                [v,k] = min ( abs( cell2mat(wollongong_keys) - frqs(jj) ) );
                closest_key = wollongong_keys(k);
                nameStr = nameStr + sprintf("(%s  *) -- ", radioContainer_woll(closest_key{1}));
                
            end
            
        end
        disp(nameStr);
        
        disp(' ');
         
        % 
        % Same as above, except lower threshold.
        % 
        
        
        [pks, frqs] = findpeaks(10*log10(fft_avg), total_freq, 'MinPeakHeight', low_thresh, 'MinPeakDistance', 200e3, 'MinPeakWidth', 2 * freq_step);
        
        frqs = round(frqs/1e6,1);
        disp([num2str(low_thresh) 'db Threshold -----> Found ' num2str(length(frqs)) ' frequency peaks ' ]);
        disp( frqs  );
       
        low_thresh_size = length(frqs);
        
        if ( low_thresh_size > (high_thresh_size + 5))
            low_thresh = low_thresh + 3;
            disp('Low threshold going up');
        end
          
        if (low_thresh_size <= ( high_thresh_size + 5) )
           low_thresh = low_thresh - 1;          
           disp('Low threshold going down');
        end
        
        if (low_thresh < (noise_floor_est + 2))        
            low_thresh = noise_floor_est + 2;
            disp('Making low threshold 2dB above noise floot estimate');
        end
        
        
        nameStr='';
        for jj=1:length(frqs)
           
            if radioContainer_woll.isKey(frqs(jj))
                nameStr = nameStr + sprintf("%s -- " , radioContainer_woll( frqs(jj)) );
                
            else
                [v,k] = min ( abs( cell2mat(wollongong_keys) - frqs(jj) ) );
                closest_key = wollongong_keys(k);
                nameStr = nameStr + sprintf("(%s  *) -- ", radioContainer_woll(closest_key{1}));
                
            end
            
        end
        disp(nameStr);
        disp(' ---- end ----- ');
        disp(' '); 
        
        fft_avg(:) = 0;
        
    end
    
    counter = counter + 1;
end

%t=0:1/sample_rate:(scanningLoops)*num_samples/sample_rate;
%t=t(1:end-1);
%pspectrum(r_t,t','spectrogram');




