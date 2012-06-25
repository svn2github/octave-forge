%{
1. Contributed by:

        Roy Smith
        Dept. of Electrical & Computer Engineering
        University of California,
	Santa Barbara, CA 93106
	U.S.A.
        roy@ece.ucsb.edu

2. Process/Description:

	The experiment is a simple SISO heating system.
	The input drives a 300 Watt Halogen lamp, suspended
	several inches above a thin steel plate.  The output
	is a thermocouple measurement taken from the back of
	the plate.

3. Sampling interval: 

	2.0 seconds

4. Number of samples

	801

5. Inputs:
        
        u: input drive voltage
        ...
6. Outputs:

        y: temperature (deg. C)
        ...
7. References:

	The use of this experiment and data for robust
	control model validation is described in:

        "Sampled Data Model Validation: an Algorithm and
        Experimental Application," Geir Dullerud & Roy Smith,
        International Journal of Robust and Nonlinear Control,
        Vol. 6, No. 9/10, pp. 1065-1078, 1996.

8. Known properties/peculiarities

	The data (and nominal model) is the above paper have the
	output expressed in 10's deg. C.  This has been rescaled 
	to the original units of deg. C. in the DaISy data set.
	There is also a -1 volt offset in u in the data shown plotted
	in the original paper.  This has been removed in the
	DaISy dataset.

	The data shows evidence of discrepancies.  One of the
	issues studied in the above paper is the size of these
	discrepancies - measured in this case in terms of the norm
	of the smallest perturbation required to account for the
	difference between the nominal model and the data.
	
	The steady state input (prior to the start of the experiment)
	is u = 6.0 Volts.

%}

clear all, close all, clc

load heating_system.dat
U=heating_system(:,2);
Y=heating_system(:,3);


dat = iddata (Y, U, 2.0, 'inname', 'input drive voltage', \
                         'inunit', 'Volt', \
                         'outname', 'temperature', \
                         'outunit', '°C')

% s=15, n=7
%[sys1, x0] = moen4 (dat, 's', 15, 'n', 7)
[sys1, x0] = moen4 (dat, 's', 15, 'n', 7, 'noise', 'k')

%sys2 = arx (dat, 7, 7)       % normally na = nb
[sys2, x02] = arx (dat, 7);

%[y1, t1] = lsim (sys1, U, [], x0);
[y1, t1] = lsim (sys1, [U, Y], [], x0);

%[y2, t] = lsim (sys2(:, 1), U);
[y2, t] = lsim (sys2, U, [], x02);


err1 = norm (Y - y1, 1) / norm (Y, 1)
err2 = norm (Y - y2, 1) / norm (Y, 1)

figure (1)
plot (t, Y, t, y1, t, y2)
title ('DaISy: Heating System [99-001]')
xlim ([t(1), t(end)])
xlabel ('Time [s]')
ylabel ('Temperature [Degree Celsius]')
legend ('measured', 'simulated subspace', 'simulated ARX', 'location', 'southeast')



