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
sys = arx (dat, 7, 7)       % normally na = nb

[y, t] = lsim (sys(:, 1), U);


err = norm (Y - y, 1) / norm (Y, 1)

figure (1)
plot (t, Y(:,1), 'b', t, y(:,1), 'r')
title ('DaISy: Heating System [99-001]')
legend ('measured temperature', 'simulated temperature', 'location', 'southeast')


[sys2, x0] = ident (dat, 15, 7)

[y2, t2] = lsim (sys2, U, [], x0);

err2 = norm (Y - y2, 1) / norm (Y, 1)

figure (2)
plot (t, Y, 'b', t, y, 'r', t, y2, 'g')
title ('DaISy: Heating System [99-001]')
legend ('measured temperature', 'simulated temperature', 'slicot', 'location', 'southeast')



