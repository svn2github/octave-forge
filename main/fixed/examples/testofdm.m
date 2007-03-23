## Copyright (C) 2003 Motorola Inc and David Bateman
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Script File} {} testofdm ()
## 
## Returns the SNR and BER of the fixed point implementation of an OFDM 
## modulator relative to its floating point implementation. Note that 
## this example assumes that the communications toolbox of octave-forge
## is installed.
## @end deftypefn

## Clear variable space and add the predecessor directory to get the fixed type
clear *;
axis();

## These are the variables to change
N = 64; 		# The size of the FFT
Nbits = 8:2:12;		# Vector of num of bits in fixed representation
Nsyms = 10;		# Number of OFDM symbols to send
Backoffs = 5:30;	# Backoff in dB from +/-1V peak-to-peak
Mod = "64QAM";		# Modulation: "BPSK", "QPSK", "16QAM", "64QAM"
fixcarriers = [ 0,  0,  0,  0,  0,  0,  1,  1,  0,  1, -1,  0,  0,  0,  0,  0;
                1,  2,  3,  4,  5,  6, 12, 26, 33, 40, 54, 60, 61, 62, 63, 64];
havewaitbar = false;    # don't use waitbar at the moment as it seems broken
                        # for cygwin

## The sole reason for the line below is to force the fixed type to be loaded
dummy = fixed(1,0,1);

## Derived quantities from fixed carriers and FFT size
Nfixedcarriers = size(fixcarriers,2);
K = N - Nfixedcarriers;

## Parse the order of modulation and create Normalisation for qaskenco
if (strcmp(Mod,"BPSK"))
  m = 1
  Norm = 1;
elseif (strcmp(Mod,"QPSK"))
  m = 2;
  Norm = sqrt(2);
elseif (strcmp(Mod,"16QAM"))
  m = 4;
  Norm = sqrt(10);
elseif (strcmp(Mod,"64QAM"))
  m = 6;
  Norm = sqrt(42);
else
  error("testfft: unknown modulation\n");
endif
M = 2 ^ m;

## Create the indexing from the [pilots, data] to the real ofdm symbol
dataidx = zeros(1,K);
k = 0;
for i=1:N
  if (!any(i == fixcarriers(2,:)))
    k++;
    dataidx(k) = i;
  endif
endfor
idx = [fixcarriers(2,:), dataidx];

## Create random data symbols and add the pilots like [pilots, data]
data = randsrc(Nsyms,K,[0:M-1]);
symspilots = ones(Nsyms,1) * fixcarriers(1,:);
symsdata = qaskenco(data,M)/Norm;
syms = [ symspilots, symsdata];

## Re-index to real OFDM symbols
syms(:,idx) = syms; 

## Create the floating-point time-domain signal
tdsignal = fifft(syms.');

## Initialize the SNR/BER and waitbar;
SNR = zeros(length(Backoffs),length(Nbits));
BER = zeros(length(Backoffs),length(Nbits));
if (havewaitbar) 
  try
    waitbar(0,"Progress");
   catch
    havewaitbar = false;
  end
endif

if (~havewaitbar)
  fprintf("                     Progress\n");
  fprintf("|---------+---------+---------+---------+---------|\n#");
  progbar = 0;
endif

for j=1:length(Backoffs)
  ## Find the normalisation of the tdsignal. Assume Vpp=+/-1 
  TdNorm = sqrt(10.^(- Backoffs(j)/10 - log10( real(tdsignal(:)' * 
				  tdsignal(:))/prod(size(tdsignal)))));
  symsnormed = syms  * TdNorm;

  ## Loop through the number of bits calculating the SNR
  for i=1:length(Nbits)
    ## Renormalize the freq domain symbols, and convert to fixed-point
    fixedsyms = fixed(0, Nbits(i), symsnormed);

    ## Create the fixed-point time-domain signal
    fixedtdsignal = fifft(fixedsyms.');

    ## Find the noise introduced by fixed-point fft
    Noise = fixedtdsignal.x(:) - tdsignal(:) * TdNorm;
    SNR(j,i) = - Backoffs(j) - 10 * log10(mean(Noise .* conj(Noise)));

    ## Reverse the modulation of the signal
    rxfixedsyms = transpose(ffft(fixedtdsignal.x)) / TdNorm;
    rxfixeddata = qaskdeco(rxfixedsyms(:,dataidx) * Norm, M);

    ## Calculate the bit error rate
    [num, BER(j,i)] = biterr(data, rxfixeddata, m);
  endfor

  if (havewaitbar)
    waitbar(j / length(Backoffs));
  else
    if (floor(50*j/length(Backoffs)) > progbar)
      while (progbar < floor(50*j/length(Backoffs)))
        fprintf("#");
	progbar++;
      endwhile
      fflush(stdout);
    endif
  endif
endfor

if (~havewaitbar)
  fprintf("\n");
endif

k = 0;
for i=1:length(Backoffs)
  if (rem(Backoffs(i),5) == 0)
    k++;
    idxbac(k) = i;
  endif
endfor

figure(1);
hold off;
__gnuplot_set__ xlabel "Backoff (dB)";
__gnuplot_set__ ylabel "SNR (dB)";
__gnuplot_set__ yrange [0:50];
dat =[0, 10; -10, -10]';
for i=1:length(Nbits)
  tit = sprintf("Rep: %d+1", Nbits(i));
  eval(["__gnuplot_plot__ dat title '" tit "' with linespoints " num2str(i) ";"]);
  hold on;
endfor
for i=1:length(Nbits)
  dat = [Backoffs', SNR(:,i)];
  eval(["__gnuplot_plot__ dat title '' with lines " num2str(i) ";"]);
endfor
for i=1:length(Nbits)
  dat = [Backoffs'(idxbac), SNR(idxbac,i)];
  eval(["__gnuplot_plot__ dat title '' with points " num2str(i) ";"]);
endfor

__gnuplot_set__ term postscript eps mono 'Times-Roman' 18;
__gnuplot_set__ output "ofdm_snr.ps"
replot
__gnuplot_set__ term x11
__gnuplot_set__ output

figure(2);
hold off;
__gnuplot_set__ xlabel "Backoff (dB)";
__gnuplot_set__ ylabel "BER";
__gnuplot_set__ yrange [1e-6:1];
__gnuplot_set__ logscale y
__gnuplot_set__ key 10.0,0.5
dat =[5, 10; 10, 10]';
for i=1:length(Nbits)
  tit = sprintf("Rep: %d+1", Nbits(i));
  eval(["__gnuplot_plot__ dat title '" tit "' with linespoints " num2str(i) ";"]);
  hold on;
endfor
for i=1:length(Nbits)
  dat = [Backoffs', BER(:,i)];
  eval(["__gnuplot_plot__ dat title '' with lines " num2str(i) ";"]);
endfor

for i=1:length(Nbits)
  dat = [Backoffs'(idxbac), BER(idxbac,i)];
  eval(["__gnuplot_plot__ dat title '' with points " num2str(i) ";"]);
endfor

__gnuplot_set__ term postscript eps mono 'Times-Roman' 18;
__gnuplot_set__ output "ofdm_ber.ps"
replot
__gnuplot_set__ nologscale y
__gnuplot_set__ term x11
__gnuplot_set__ output
__gnuplot_set__ key

