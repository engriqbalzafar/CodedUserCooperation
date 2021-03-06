%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Written By: ZAFAR IQBAL                                                 %
%             Gwangju Institute of Science and Technology, South Korea    %
% Date: Jan 18, 2013.                                                     %
% Modification History:                                                   %
% Jan 18, 2013... Current version created.                                %
%                                                                         %
%                                                                         %
%                                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function coded_user_coop()

clear all;
%close all;
%Initializing the simulation parameters
max = 1000; %maximum number of symbols to transmit or number of errors per SNR.
m=20; %Codeword size for LDGM
d=7;  %Number of 1s in each column of H for LDGM
k=20; %Number of rows of H for LDGM
n = k+m;
Es1 = 1;
Es2 = 1;

SNR = 0:15;


for x=1:length(SNR) % SNR range for simulation
    
    BitErrorsLDGM = 0;
    WordErrorsLDGM = 0;
    TotBitsLDGM =0;
    TotWordsLDGM =0;
    
    [G Q1LDGM Q2LDGM j_limit k_limit] = ldgm_G(m,d,k); % Generate G matrix for LDGM coding
    %size(G)

    R_LDGM = k/n;
    
    % EsN0 calculation
    Ec1 = Es1;
    Ec2 = Es2;
    %Es = (Es1+Es2)/2;
    EbN0 = 10^(SNR(x)/10);
    N0coded = (1/EbN0)*(Ec2/R_LDGM); % Noise variance for phase 2, LDGM coded transmission
    %EsN0 = EbN0*R_LDGM; %Es/N0coded;
    
    N0uncoded = (1/EbN0)*Ec1; % Noise variance for phase 1, uncoded transmission
    N01 = (1/(10^((SNR(x)+50)/10)))*Ec1; % Inter-user channel noise variance (20 dB)

    % Compute the Pe for first phase BSC channel error
    %pbar=1/2*(1-sqrt((Ec1*1/N01)/(1+(Ec1*1/N01))));
    pbar= 1/2* erfc((sqrt(2*Ec1/N0uncoded))/sqrt(2));
    %pbar=1/2*(1-sqrt(EbN0/(1+EbN0)));
    %pe=1/2*erfc(sqrt(Ec1/N0uncoded));
    %pbar=0.001;
    pe=(1-(1-2*pbar)^d)/2;
    %pe=0.0001;
    %Monte Carlo Simulation
    
    while TotWordsLDGM <= max %Maximum number of words for the particular SNR
        %[G Q1LDGM Q2LDGM j_limit k_limit] = ldgm_G(m,d,k); % Generate G matrix for LDGM coding
        %Generating a random binary message of length k
        message = rand(1,k)<0.5;
         
        %Transmitting the message in the form of BPSK
        Tx_uncoded = sqrt(Ec1)*((2 * message) - 1);     
        
        %Passing through BSC before being relayed
        relay_rx = bsc(real(message), pe);
        
        %Converting the message received at relay, into codeword bits of the LDGM code
        ldgm_coded = mod(relay_rx*G,2);
                    
        %Transmitting the codewords in the form of BPSK
        Tx_coded = sqrt(Ec2)*((2 * ldgm_coded) - 1);
        
%          % Generating channel response
%          h=rayleigh_channel(5E3, 1);
%          h=h(1:length(Tx_coded));
%          
%          noise = sqrt(N0./2).*(randn(size(Tx_coded))+ 1i.*randn(size(Tx_coded))); % Generating Gaussian noise
%          Rx_signal = h.* Tx_coded + noise; % Adding noise
%          Rx_signal = real(Rx_signal./h); % Assuming ideal channel estimation
          %Rx_signal = Tx_coded+noise;
%         h=rayleighchan(1/10000, 10);%, 1.0e-004 * [0 0.0100 0.0200 0.0300], [0 -1 -2 -3]);
%                         %CHAN = RICIANCHAN(TS, FD, K) constructs a frequency-flat ("single
%                         %path") Rician fading channel object.  TS is the sample time of the
%                         %input signal, in seconds.  FD is the maximum Doppler shift, in Hertz. K
%                         %is the Rician K-factor in linear scale.
%         changain=filter(h,ones(1,length(Tx_coded)));
%         %a=max(max(abs(changain)));
%         %changain=changain./a;
% 
%         % chan_data = changain.*Tx_coded;
%         %[rec_rician rec_rayleigh] = fading_channel(Tx_coded);
%         noise = sqrt(No./2).*(randn(size(Tx_coded))+ 1i.*randn(size(Tx_coded))); % Generating Gaussian noise
%         Rx_signal = changain.* Tx_coded + noise; % Adding noise
%         Rx_signal = real(Rx_signal./changain); % Assuming ideal channel estimation
        
        h1 = 1/sqrt(2)*(randn(size(Tx_uncoded)) + 1i*randn(size(Tx_uncoded))); % Rayleigh channel for uncoded data
        %h1 = h1./norm(h1,2);
        h2 = 1/sqrt(2)*(randn(size(Tx_coded)) + 1i*randn(size(Tx_coded))); % Rayleigh channel for coded data
        %h2 = h2./norm(h2,2);
        noise1 = sqrt(N0uncoded./2).*(randn(size(Tx_uncoded))+ 1i.*randn(size(Tx_uncoded))); % Generating Gaussian noise
        noise2 = sqrt(N0coded./2).*(randn(size(Tx_coded))+ 1i.*randn(size(Tx_coded))); % Generating Gaussian noise
        
%         changain1=filter(h1,ones(1,length(Tx_uncoded)),Tx_uncoded);
%         a1=max(max(abs(changain1)));
%         changain1=changain1./a1;
%         changain2=filter(h2,ones(1,length(Tx_coded)),Tx_coded);
%         a2=max(max(abs(changain2)));
%         changain2=changain2./a2;
%         rx_uncoded = [conv(h1,(sqrt(Ec1)*Tx_uncoded)) 0];
%         rx_coded = [conv(h2,(sqrt(Ec1)*Tx_coded)) 0];
%         noise1 = sqrt(N0uncoded./2).*(randn(size(rx_uncoded))+ 1i.*randn(size(rx_uncoded))); % Generating Gaussian noise
%         noise2 = sqrt(N0coded./2).*(randn(size(rx_coded))+ 1i.*randn(size(rx_coded))); % Generating Gaussian noise
        rx_uncoded = h1.*Tx_uncoded + noise1;
        rx_coded = h2.*Tx_coded + noise2;
        
        % Channel estimation
        H1 = fft(h1,k);
        H2 = fft(h2,m);
        % Signal estimation
        rx_hat_p1 = real(rx_uncoded./h1);
        rx_hat_p2 = real(rx_coded./h2);
        
        %Rx_uncoded = awgn(Tx_uncoded, SNR(x)); % For AWGN channel
        %Rx_coded = awgn(Tx_coded, SNR(x)); % For AWGN channel
        
        % Received signal decoding
        [output_LDGM] = decode_LDGM(rx_hat_p1, rx_hat_p2, n, j_limit, k_limit, Q1LDGM, Q2LDGM, Ec1, Ec2, N0coded, N0uncoded, h1, h2, pe);
        %output_LDGM
        TotBitsLDGM = TotBitsLDGM + length(message); % Total no. of bits sent
        TotWordsLDGM = TotWordsLDGM + 1;
        %[message ldgm_coded]
        
        BitErrorsLDGM = BitErrorsLDGM + length(find(message ~= output_LDGM(1:length(message))));
              
%         if length(find([message ldgm_coded] ~= output_LDGM)) >= 1
%             WordErrorsLDGM = WordErrorsLDGM +1;
%         end
   end
 
    BER_CUCcoded(x) = BitErrorsLDGM/TotBitsLDGM; % BER for the particular SNR
    %WER_LDGMcoded(x) = WordErrorsLDGM/TotWordsLDGM; %WER for the particular SNR
    
    BER_uncoded(x) = 1/2*erfc(sqrt(EbN0)); % Computing BER for the AWGN uncoded case
    BER_BPSKrayleigh(x) = 1/2.*(1-sqrt(EbN0./(EbN0+1))); % Computing BER for the Rayleigh uncoded case
%     WER_uncoded(x) = 1 - (1 - BER_uncoded(x))^(n); % Computing WER for the uncoded case
           
    fprintf('\nSimulation done for SNR: %d\n',SNR(x));
end
    % Result storage
    save_mat_name = ['./results/BER_Theory_n' int2str(n) 'd' int2str(d) 'k' int2str(k)];
    save (save_mat_name,'BER_BPSKrayleigh');
%     save_mat_name = ['./results/WER_Theory_n' int2str(n) 'j' int2str(j) 'k' int2str(k)];
%     save (save_mat_name,'WER_uncoded');
    save_mat_name = ['./results/BER_CUC_n' int2str(n) 'd' int2str(d) 'k' int2str(k)];
    save (save_mat_name,'BER_CUCcoded');
%     save_mat_name = ['./results/WER_LDGM_n' int2str(n) 'j' int2str(j) 'k' int2str(k)];
%     save (save_mat_name,'WER_LDGMcoded');
    
    % Loading saved results for plotting
    load_mat_name = ['./results/BER_CUC_n' int2str(n) 'd' int2str(d) 'k' int2str(k)];
    load(load_mat_name);
    BER_CUC = BER_CUCcoded;
%     load_mat_name = ['./results/WER_LDGM_n' int2str(n) 'j' int2str(j) 'k' int2str(k)];
%     load(load_mat_name);
%     WER_LDGM = WER_LDGMcoded;

    load_mat_name = ['./results/BER_Theory_n' int2str(n) 'd' int2str(d) 'k' int2str(k)];
    load(load_mat_name);
    BER_Theory = BER_BPSKrayleigh;
%     load_mat_name = ['./results/WER_Theory_n' int2str(n) 'j' int2str(j) 'k' int2str(k)];
%     load(load_mat_name);
%     WER_Theory = WER_uncoded;

figure(1) %Plotting the graph for BER
semilogy(SNR, BER_CUC,'g-o'),hold
%semilogy(SNR, WER_LDGMcoded,'g-s'),
semilogy(SNR, BER_Theory,'b-x'),
legend('Coded User Cooperation','BPSK Theory');
title(['Bit Error Rate, CUC Code n=',num2str(n), ', d=',num2str(d),', k=',num2str(k)]),
ylabel('BER'),
xlabel('SNR (dB)'),
grid,

% figure(2) % Plotting the graph for WER
% semilogy(SNR, WER_LDGM, 'g-o'), hold
% semilogy(SNR, WER_Theory, 'b-x'),
% legend('LDGM Code','BPSK Theory');
% title(['Word Error Rate, LDGM Code n=',num2str(n), ', j=',num2str(j),', k=',num2str(k)]),
% ylabel('WER'),
% xlabel('SNR (dB)'),
% grid,

%end