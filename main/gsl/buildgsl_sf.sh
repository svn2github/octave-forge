## Copyright (C) 2004   Teemu Ikonen   <tpikonen@pcu.helsinki.fi>
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


cat precode.cc.template > gsl_sf.cc

# double to double

export octave_name=clausen
export    funcname=gsl_sf_clausen
cat << \EOF > docstring.txt
The Clausen function is defined by the following integral,

Cl_2(x) = - \int_0^x dt \log(2 \sin(t/2))

It is related to the dilogarithm by Cl_2(\theta) = \Im Li_2(\exp(i \theta)).
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=dawson
export    funcname=gsl_sf_dawson
cat << \EOF > docstring.txt
The Dawson integral is defined by \exp(-x^2) \int_0^x dt \exp(t^2).
A table of Dawson's integral can be found in Abramowitz & Stegun, Table 7.5.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=debye_1
export    funcname=gsl_sf_debye_1
cat << \EOF > docstring.txt
The Debye functions are defined by the integral 

D_n(x) = n/x^n \int_0^x dt (t^n/(e^t - 1)).

For further information see Abramowitz & Stegun, Section 27.1.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=debye_2
export    funcname=gsl_sf_debye_2
cat << \EOF > docstring.txt
The Debye functions are defined by the integral

D_n(x) = n/x^n \int_0^x dt (t^n/(e^t - 1)).

For further information see Abramowitz & Stegun, Section 27.1.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=debye_3
export    funcname=gsl_sf_debye_3
cat << \EOF > docstring.txt
The Debye functions are defined by the integral

D_n(x) = n/x^n \int_0^x dt (t^n/(e^t - 1)).

For further information see Abramowitz & Stegun, Section 27.1.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=debye_4
export    funcname=gsl_sf_debye_4
cat << \EOF > docstring.txt
The Debye functions are defined by the integral

D_n(x) = n/x^n \int_0^x dt (t^n/(e^t - 1)).

For further information see Abramowitz & Stegun, Section 27.1.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=erf_gsl
export    funcname=gsl_sf_erf 
cat << \EOF > docstring.txt
These routines compute the error function 
erf(x) = (2/\sqrt(\pi)) \int_0^x dt \exp(-t^2).
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc

export octave_name=erfc_gsl
export    funcname=gsl_sf_erfc
cat << \EOF > docstring.txt
These routines compute the complementary error function 
erfc(x) = 1 - erf(x) = (2/\sqrt(\pi)) \int_x^\infty \exp(-t^2).
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc

export octave_name=log_erfc
export    funcname=gsl_sf_log_erfc
cat << \EOF > docstring.txt
These routines compute the logarithm of the complementary error
function \log(\erfc(x)).
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc

export octave_name=erf_Z
export    funcname=gsl_sf_erf_Z
cat << \EOF > docstring.txt
These routines compute the Gaussian probability function 
Z(x) = (1/(2\pi)) \exp(-x^2/2).
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc

export octave_name=erf_Q
export    funcname=gsl_sf_erf_Q
cat << \EOF > docstring.txt
These routines compute the upper tail of the Gaussian probability
function  Q(x) = (1/(2\pi)) \int_x^\infty dt \exp(-t^2/2).
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=hazard
export    funcname=gsl_sf_hazard
cat << \EOF > docstring.txt
The hazard function for the normal distrbution, also known as the 
inverse Mill's ratio, is defined as 
h(x) = Z(x)/Q(x) = \sqrt{2/\pi \exp(-x^2 / 2) / \erfc(x/\sqrt 2)}. 
It decreases rapidly as x approaches -\infty and asymptotes to 
h(x) \sim x as x approaches +\infty.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=expm1
export    funcname=gsl_sf_expm1
cat << \EOF > docstring.txt
These routines compute the quantity \exp(x)-1 using an algorithm that 
is accurate for small x.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=exprel
export    funcname=gsl_sf_exprel 
cat << \EOF > docstring.txt
These routines compute the quantity (\exp(x)-1)/x using an algorithm 
that is accurate for small x. For small x the algorithm is based on 
the expansion (\exp(x)-1)/x = 1 + x/2 + x^2/(2*3) + x^3/(2*3*4) + \dots.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=exprel_2
export    funcname=gsl_sf_exprel_2
cat << \EOF > docstring.txt
These routines compute the quantity 2(\exp(x)-1-x)/x^2 using an
algorithm that is accurate for small x. For small x the algorithm is 
based on the expansion 
2(\exp(x)-1-x)/x^2 = 1 + x/3 + x^2/(3*4) + x^3/(3*4*5) + \dots.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=expint_E1
export    funcname=gsl_sf_expint_E1
cat << \EOF > docstring.txt
These routines compute the exponential integral E_1(x),

E_1(x) := Re \int_1^\infty dt \exp(-xt)/t.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=expint_E2
export    funcname=gsl_sf_expint_E2
cat << \EOF > docstring.txt
These routines compute the second-order exponential integral E_2(x),

E_2(x) := \Re \int_1^\infty dt \exp(-xt)/t^2.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=expint_Ei
export    funcname=gsl_sf_expint_Ei
cat << \EOF > docstring.txt
These routines compute the exponential integral E_i(x),

Ei(x) := - PV(\int_{-x}^\infty dt \exp(-t)/t)

where PV denotes the principal value of the integral.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=Shi
export    funcname=gsl_sf_Shi
cat << \EOF > docstring.txt
These routines compute the integral Shi(x) = \int_0^x dt \sinh(t)/t.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=Chi
export    funcname=gsl_sf_Chi
cat << \EOF > docstring.txt
These routines compute the integral 

Chi(x) := Re[ \gamma_E + \log(x) + \int_0^x dt (\cosh[t]-1)/t] , 

where \gamma_E is the Euler constant.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=expint_3
export    funcname=gsl_sf_expint_3
cat << \EOF > docstring.txt
These routines compute the exponential integral 
Ei_3(x) = \int_0^x dt \exp(-t^3) for x >= 0.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=Si
export    funcname=gsl_sf_Si
cat << \EOF > docstring.txt
These routines compute the Sine integral Si(x) = \int_0^x dt \sin(t)/t.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=Ci
export    funcname=gsl_sf_Ci
cat << \EOF > docstring.txt
These routines compute the Cosine integral 
Ci(x) = -\int_x^\infty dt \cos(t)/t for x > 0. 
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=atanint
export    funcname=gsl_sf_atanint
cat << \EOF > docstring.txt
These routines compute the Arctangent integral 
AtanInt(x) = \int_0^x dt \arctan(t)/t. 
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=fermi_dirac_mhalf
export    funcname=gsl_sf_fermi_dirac_mhalf
cat << \EOF > docstring.txt
These routines compute the complete Fermi-Dirac integral F_{-1/2}(x).
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=fermi_dirac_half
export    funcname=gsl_sf_fermi_dirac_half
cat << \EOF > docstring.txt
These routines compute the complete Fermi-Dirac integral F_{1/2}(x).
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=fermi_dirac_3half
export    funcname=gsl_sf_fermi_dirac_3half
cat << \EOF > docstring.txt
These routines compute the complete Fermi-Dirac integral F_{3/2}(x).
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=gamma_gsl
export    funcname=gsl_sf_gamma
cat << \EOF > docstring.txt
These routines compute the Gamma function \Gamma(x), subject to x not 
being a negative integer. The function is computed using the real 
Lanczos method. The maximum value of x such that \Gamma(x) is not 
considered an overflow is given by the macro GSL_SF_GAMMA_XMAX and is 171.0.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=lngamma_gsl
export    funcname=gsl_sf_lngamma
cat << \EOF > docstring.txt
These routines compute the logarithm of the Gamma function, 
\log(\Gamma(x)), subject to x not a being negative integer. 
For x<0 the real part of \log(\Gamma(x)) is returned, which is 
equivalent to \log(|\Gamma(x)|). The function is computed using 
the real Lanczos method.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=gammastar
export    funcname=gsl_sf_gammastar
cat << \EOF > docstring.txt
These routines compute the regulated Gamma Function \Gamma^*(x) 
for x > 0. The regulated gamma function is given by,

\Gamma^*(x) = \Gamma(x)/(\sqrt{2\pi} x^{(x-1/2)} \exp(-x))
            = (1 + (1/12x) + ...)  for x \to \infty

and is a useful suggestion of Temme. 
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=gammainv_gsl
export    funcname=gsl_sf_gammainv
cat << \EOF > docstring.txt
These routines compute the reciprocal of the gamma function, 1/\Gamma(x) using the real Lanczos method.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=lambert_W0
export    funcname=gsl_sf_lambert_W0
cat << \EOF > docstring.txt
These compute the principal branch of the Lambert W function, W_0(x).

Lambert's W functions, W(x), are defined to be solutions of the
equation W(x) \exp(W(x)) = x. This function has multiple branches 
for x < 0; however, it has only two real-valued branches. 
We define W_0(x) to be the principal branch, where W > -1 for x < 0, 
and W_{-1}(x) to be the other real branch, where W < -1 for x < 0.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=lambert_Wm1
export    funcname=gsl_sf_lambert_Wm1
cat << \EOF > docstring.txt
These compute the secondary real-valued branch of the Lambert 
W function, W_{-1}(x).

Lambert's W functions, W(x), are defined to be solutions of the
equation W(x) \exp(W(x)) = x. This function has multiple branches 
for x < 0; however, it has only two real-valued branches. 
We define W_0(x) to be the principal branch, where W > -1 for x < 0, 
and W_{-1}(x) to be the other real branch, where W < -1 for x < 0.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=log_1plusx
export    funcname=gsl_sf_log_1plusx
cat << \EOF > docstring.txt
These routines compute \log(1 + x) for x > -1 using an algorithm that
is accurate for small x.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=log_1plusx_mx
export    funcname=gsl_sf_log_1plusx_mx
cat << \EOF > docstring.txt
These routines compute \log(1 + x) - x for x > -1 using an algorithm 
that is accurate for small x.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=psi
export    funcname=gsl_sf_psi
cat << \EOF > docstring.txt
These routines compute the digamma function \psi(x) for general x, 
x \ne 0.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=psi_1piy
export    funcname=gsl_sf_psi_1piy
cat << \EOF > docstring.txt
These routines compute the real part of the digamma function on 
the line 1+i y, Re[\psi(1 + i y)].
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=synchrotron_1
export    funcname=gsl_sf_synchrotron_1
cat << \EOF > docstring.txt
These routines compute the first synchrotron function 
x \int_x^\infty dt K_{5/3}(t) for x >= 0.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=synchrotron_2
export    funcname=gsl_sf_synchrotron_2
cat << \EOF > docstring.txt
These routines compute the second synchrotron function 
x K_{2/3}(x) for x >= 0.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=transport_2
export    funcname=gsl_sf_transport_2
cat << \EOF > docstring.txt
These routines compute the transport function J(2,x).

The transport functions J(n,x) are defined by the integral
representations J(n,x) := \int_0^x dt t^n e^t /(e^t - 1)^2.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=transport_3
export    funcname=gsl_sf_transport_3
cat << \EOF > docstring.txt
These routines compute the transport function J(3,x).

The transport functions J(n,x) are defined by the integral
representations J(n,x) := \int_0^x dt t^n e^t /(e^t - 1)^2.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=transport_4
export    funcname=gsl_sf_transport_4
cat << \EOF > docstring.txt
These routines compute the transport function J(4,x).

The transport functions J(n,x) are defined by the integral
representations J(n,x) := \int_0^x dt t^n e^t /(e^t - 1)^2.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=transport_5
export    funcname=gsl_sf_transport_5
cat << \EOF > docstring.txt
These routines compute the transport function J(5,x).

The transport functions J(n,x) are defined by the integral
representations J(n,x) := \int_0^x dt t^n e^t /(e^t - 1)^2.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=lnsinh
export    funcname=gsl_sf_lnsinh
cat << \EOF > docstring.txt
These routines compute \log(\sinh(x)) for x > 0.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=lncosh
export    funcname=gsl_sf_lncosh
cat << \EOF > docstring.txt
These routines compute \log(\cosh(x)) for any x.
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=zeta
export    funcname=gsl_sf_zeta
cat << \EOF > docstring.txt
These routines compute the Riemann zeta function \zeta(s) for 
arbitrary s, s \ne 1.

The Riemann zeta function is defined by the infinite sum 
\zeta(s) = \sum_{k=1}^\infty k^{-s}. 
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc


export octave_name=eta
export    funcname=gsl_sf_eta
cat << \EOF > docstring.txt
These routines compute the eta function \eta(s) for arbitrary s.

The eta function is defined by \eta(s) = (1-2^{1-s}) \zeta(s).
EOF
./replace_template.sh double_to_double.cc.template >> gsl_sf.cc



# (int, double) to double

export octave_name=bessel_Jn
export    funcname=gsl_sf_bessel_Jn
cat << \EOF > docstring.txt
These routines compute the regular cylindrical Bessel function of
order n, J_n(x).
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_Yn
export    funcname=gsl_sf_bessel_Yn
cat << \EOF > docstring.txt
These routines compute the irregular cylindrical Bessel function of 
order n, Y_n(x), for x>0.
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_In
export    funcname=gsl_sf_bessel_In
cat << \EOF > docstring.txt
These routines compute the regular modified cylindrical Bessel
function of order n, I_n(x).
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_In_scaled
export    funcname=gsl_sf_bessel_In_scaled
cat << \EOF > docstring.txt
These routines compute the scaled regular modified cylindrical Bessel
function of order n, \exp(-|x|) I_n(x)
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_Kn
export    funcname=gsl_sf_bessel_Kn
cat << \EOF > docstring.txt
These routines compute the irregular modified cylindrical Bessel
function of order n, K_n(x), for x > 0.
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_Kn_scaled
export    funcname=gsl_sf_bessel_Kn_scaled
cat << \EOF > docstring.txt

EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_jl
export    funcname=gsl_sf_bessel_jl
cat << \EOF > docstring.txt
These routines compute the regular spherical Bessel function of 
order l, j_l(x), for l >= 0 and x >= 0.
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_yl
export    funcname=gsl_sf_bessel_yl
cat << \EOF > docstring.txt
These routines compute the irregular spherical Bessel function of
order l, y_l(x), for l >= 0.
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_il_scaled
export    funcname=gsl_sf_bessel_il_scaled
cat << \EOF > docstring.txt
These routines compute the scaled regular modified spherical Bessel
function of order l, \exp(-|x|) i_l(x)
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_kl_scaled
export    funcname=gsl_sf_bessel_kl_scaled
cat << \EOF > docstring.txt
These routines compute the scaled irregular modified spherical Bessel
function of order l, \exp(x) k_l(x), for x>0.
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=exprel_n
export    funcname=gsl_sf_exprel_n
cat << \EOF > docstring.txt
These routines compute the N-relative exponential, which is the n-th
generalization of the functions gsl_sf_exprel and gsl_sf_exprel2. The
N-relative exponential is given by,

exprel_N(x) = N!/x^N (\exp(x) - \sum_{k=0}^{N-1} x^k/k!)
            = 1 + x/(N+1) + x^2/((N+1)(N+2)) + ...
            = 1F1 (1,1+N,x)
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=fermi_dirac_int
export    funcname=gsl_sf_fermi_dirac_int
cat << \EOF > docstring.txt
These routines compute the complete Fermi-Dirac integral with an
integer index of j, F_j(x) = (1/\Gamma(j+1)) \int_0^\infty dt (t^j
/(\exp(t-x)+1)).
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=taylorcoeff
export    funcname=gsl_sf_taylorcoeff
cat << \EOF > docstring.txt
These routines compute the Taylor coefficient x^n / n! 
for x >= 0, n >= 0.
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=legendre_Pl
export    funcname=gsl_sf_legendre_Pl
cat << \EOF > docstring.txt
These functions evaluate the Legendre polynomial P_l(x) for a specific
value of l, x subject to l >= 0, |x| <= 1
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=legendre_Ql 
export    funcname=gsl_sf_legendre_Ql 
cat << \EOF > docstring.txt
These routines compute the Legendre function Q_l(x) for x > -1, x != 1
and l >= 0.
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=psi_n
export    funcname=gsl_sf_psi_n
cat << \EOF > docstring.txt
These routines compute the polygamma function \psi^{(m)}(x) 
for m >= 0, x > 0.
EOF
./replace_template.sh int_double_to_double.cc.template >> gsl_sf.cc



# (double, double) to double

export octave_name=bessel_Jnu
export    funcname=gsl_sf_bessel_Jnu
cat << \EOF > docstring.txt
These routines compute the regular cylindrical Bessel function of
fractional order nu, J_\nu(x).
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_Ynu
export    funcname=gsl_sf_bessel_Ynu
cat << \EOF > docstring.txt
These routines compute the irregular cylindrical Bessel function of
fractional order nu, Y_\nu(x).
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_Inu
export    funcname=gsl_sf_bessel_Inu
cat << \EOF > docstring.txt
These routines compute the regular modified Bessel function of
fractional order nu, I_\nu(x) for x>0, \nu>0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_Inu_scaled
export    funcname=gsl_sf_bessel_Inu_scaled
cat << \EOF > docstring.txt
These routines compute the scaled regular modified Bessel function of
fractional order nu, \exp(-|x|)I_\nu(x) for x>0, \nu>0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_Knu
export    funcname=gsl_sf_bessel_Knu
cat << \EOF > docstring.txt
These routines compute the irregular modified Bessel function of
fractional order nu, K_\nu(x) for x>0, \nu>0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_lnKnu
export    funcname=gsl_sf_bessel_lnKnu
cat << \EOF > docstring.txt
These routines compute the logarithm of the irregular modified Bessel
function of fractional order nu, \ln(K_\nu(x)) for x>0, \nu>0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_Knu_scaled
export    funcname=gsl_sf_bessel_Knu_scaled
cat << \EOF > docstring.txt
These routines compute the scaled irregular modified Bessel function
of fractional order nu, \exp(+|x|) K_\nu(x) for x>0, \nu>0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=exp_mult
export    funcname=gsl_sf_exp_mult
cat << \EOF > docstring.txt
These routines exponentiate x and multiply by the factor y to return
the product y \exp(x).
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=fermi_dirac_inc_0
export    funcname=gsl_sf_fermi_dirac_inc_0
cat << \EOF > docstring.txt
These routines compute the incomplete Fermi-Dirac integral with an
index of zero, F_0(x,b) = \ln(1 + e^{b-x}) - (b-x).
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=poch
export    funcname=gsl_sf_poch
cat << \EOF > docstring.txt
These routines compute the Pochhammer symbol 

(a)_x := \Gamma(a + x)/\Gamma(a), 

subject to a and a+x not being negative integers. The Pochhammer
symbol is also known as the Apell symbol.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=lnpoch
export    funcname=gsl_sf_lnpoch
cat << \EOF > docstring.txt
These routines compute the logarithm of the Pochhammer symbol,
\log((a)_x) = \log(\Gamma(a + x)/\Gamma(a)) for a > 0, a+x > 0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=pochrel
export    funcname=gsl_sf_pochrel
cat << \EOF > docstring.txt
These routines compute the relative Pochhammer symbol ((a,x) - 1)/x
where (a,x) = (a)_x := \Gamma(a + x)/\Gamma(a).
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=gamma_inc_Q
export    funcname=gsl_sf_gamma_inc_Q
cat << \EOF > docstring.txt
These routines compute the normalized incomplete Gamma Function 
Q(a,x) = 1/\Gamma(a) \int_x\infty dt t^{a-1} \exp(-t) for a > 0, x >= 0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=gamma_inc_P
export    funcname=gsl_sf_gamma_inc_P
cat << \EOF > docstring.txt
These routines compute the complementary normalized incomplete Gamma
Function P(a,x) = 1/\Gamma(a) \int_0^x dt t^{a-1} \exp(-t) 
for a > 0, x >= 0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=gamma_inc
export    funcname=gsl_sf_gamma_inc
cat << \EOF > docstring.txt
These functions compute the incomplete Gamma Function the
normalization factor included in the previously defined functions:
\Gamma(a,x) = \int_x\infty dt t^{a-1} \exp(-t) for a real and x >= 0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=beta_gsl
export    funcname=gsl_sf_beta
cat << \EOF > docstring.txt
These routines compute the Beta Function, 
B(a,b) = \Gamma(a)\Gamma(b)/\Gamma(a+b) for a > 0, b > 0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=lnbeta
export    funcname=gsl_sf_lnbeta
cat << \EOF > docstring.txt
These routines compute the logarithm of the Beta Function,
\log(B(a,b)) for a > 0, b > 0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=hyperg_0F1
export    funcname=gsl_sf_hyperg_0F1
cat << \EOF > docstring.txt
These routines compute the hypergeometric function 0F1(c,x).
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=conicalP_half
export    funcname=gsl_sf_conicalP_half
cat << \EOF > docstring.txt
These routines compute the irregular Spherical Conical Function
P^{1/2}_{-1/2 + i \lambda}(x) for x > -1.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=conicalP_mhalf
export    funcname=gsl_sf_conicalP_mhalf
cat << \EOF > docstring.txt
These routines compute the regular Spherical Conical Function
P^{-1/2}_{-1/2 + i \lambda}(x) for x > -1.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=conicalP_0
export    funcname=gsl_sf_conicalP_0
cat << \EOF > docstring.txt
These routines compute the conical function P^0_{-1/2 + i \lambda}(x)
for x > -1.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=conicalP_1
export    funcname=gsl_sf_conicalP_1
cat << \EOF > docstring.txt
These routines compute the conical function P^1_{-1/2 + i \lambda}(x)
for x > -1.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc


export octave_name=hzeta
export    funcname=gsl_sf_hzeta
cat << \EOF > docstring.txt
These routines compute the Hurwitz zeta function \zeta(s,q) 
for s > 1, q > 0.
EOF
./replace_template.sh double_double_to_double.cc.template >> gsl_sf.cc



# (double, mode) to double

export octave_name=airy_Ai
export    funcname=gsl_sf_airy_Ai
cat << \EOF > docstring.txt
These routines compute the Airy function Ai(x) with an accuracy
specified by mode.
EOF
./replace_template.sh double_mode_to_double.cc.template >> gsl_sf.cc


export octave_name=airy_Bi
export    funcname=gsl_sf_airy_Bi
cat << \EOF > docstring.txt
These routines compute the Airy function Bi(x) with an accuracy
specified by mode.
EOF
./replace_template.sh double_mode_to_double.cc.template >> gsl_sf.cc


export octave_name=airy_Ai_scaled
export    funcname=gsl_sf_airy_Ai_scaled
cat << \EOF > docstring.txt
These routines compute a scaled version of the Airy function 
S_A(x) Ai(x). For x>0 the scaling factor S_A(x) is \exp(+(2/3) x^(3/2)), and
is 1 for x<0.
EOF
./replace_template.sh double_mode_to_double.cc.template >> gsl_sf.cc


export octave_name=airy_Bi_scaled
export    funcname=gsl_sf_airy_Bi_scaled
cat << \EOF > docstring.txt
These routines compute a scaled version of the Airy function 
S_B(x) Bi(x). For x>0 the scaling factor S_B(x) is exp(-(2/3) x^(3/2)), and
is 1 for x<0.
EOF
./replace_template.sh double_mode_to_double.cc.template >> gsl_sf.cc


export octave_name=airy_Ai_deriv
export    funcname=gsl_sf_airy_Ai_deriv
cat << \EOF > docstring.txt
These routines compute the Airy function derivative Ai'(x) with an
accuracy specified by mode.
EOF
./replace_template.sh double_mode_to_double.cc.template >> gsl_sf.cc


export octave_name=airy_Bi_deriv
export    funcname=gsl_sf_airy_Bi_deriv
cat << \EOF > docstring.txt
These routines compute the Airy function derivative Bi'(x) with an
accuracy specified by mode.
EOF
./replace_template.sh double_mode_to_double.cc.template >> gsl_sf.cc


export octave_name=airy_Ai_deriv_scaled
export    funcname=gsl_sf_airy_Ai_deriv_scaled
cat << \EOF > docstring.txt
These routines compute the derivative of the scaled Airy function
S_A(x) Ai(x).
EOF
./replace_template.sh double_mode_to_double.cc.template >> gsl_sf.cc


export octave_name=airy_Bi_deriv_scaled
export    funcname=gsl_sf_airy_Bi_deriv_scaled
cat << \EOF > docstring.txt
These routines compute the derivative of the scaled Airy function
S_B(x) Bi(x).
EOF
./replace_template.sh double_mode_to_double.cc.template >> gsl_sf.cc


export octave_name=ellint_Kcomp
export    funcname=gsl_sf_ellint_Kcomp
cat << \EOF > docstring.txt
These routines compute the complete elliptic integral K(k) to the
accuracy specified by the mode variable mode.
EOF
./replace_template.sh double_mode_to_double.cc.template >> gsl_sf.cc


export octave_name=ellint_Ecomp
export    funcname=gsl_sf_ellint_Ecomp
cat << \EOF > docstring.txt
These routines compute the complete elliptic integral E(k) to the
accuracy specified by the mode variable mode.
EOF
./replace_template.sh double_mode_to_double.cc.template >> gsl_sf.cc



# int to double

export octave_name=airy_zero_Ai
export    funcname=gsl_sf_airy_zero_Ai
cat << \EOF > docstring.txt
These routines compute the location of the s-th zero of the Airy
function Ai(x).
EOF
./replace_template.sh int_to_double.cc.template >> gsl_sf.cc


export octave_name=airy_zero_Bi
export    funcname=gsl_sf_airy_zero_Bi
cat << \EOF > docstring.txt
These routines compute the location of the s-th zero of the Airy
function Bi(x).
EOF
./replace_template.sh int_to_double.cc.template >> gsl_sf.cc


export octave_name=airy_zero_Ai_deriv
export    funcname=gsl_sf_airy_zero_Ai_deriv
cat << \EOF > docstring.txt
These routines compute the location of the s-th zero of the Airy
function derivative Ai'(x).
EOF
./replace_template.sh int_to_double.cc.template >> gsl_sf.cc


export octave_name=airy_zero_Bi_deriv
export    funcname=gsl_sf_airy_zero_Bi_deriv
cat << \EOF > docstring.txt
These routines compute the location of the s-th zero of the Airy
function derivative Bi'(x).
EOF
./replace_template.sh int_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_zero_J0
export    funcname=gsl_sf_bessel_zero_J0
cat << \EOF > docstring.txt
These routines compute the location of the s-th positive zero of the
Bessel function J_0(x).
EOF
./replace_template.sh int_to_double.cc.template >> gsl_sf.cc


export octave_name=bessel_zero_J1
export    funcname=gsl_sf_bessel_zero_J1
cat << \EOF > docstring.txt
These routines compute the location of the s-th positive zero of the
Bessel function J_1(x).
EOF
./replace_template.sh int_to_double.cc.template >> gsl_sf.cc


export octave_name=psi_1_int
export    funcname=gsl_sf_psi_1_int
cat << \EOF > docstring.txt
These routines compute the Trigamma function \psi'(n) for positive
integer n.
EOF
./replace_template.sh int_to_double.cc.template >> gsl_sf.cc


export octave_name=zeta_int
export    funcname=gsl_sf_zeta_int
cat << \EOF > docstring.txt
These routines compute the Riemann zeta function \zeta(n) for 
integer n, n \ne 1.
EOF
./replace_template.sh int_to_double.cc.template >> gsl_sf.cc


export octave_name=eta_int
export    funcname=gsl_sf_eta_int
cat << \EOF > docstring.txt
These routines compute the eta function \eta(n) for integer n.
EOF
./replace_template.sh int_to_double.cc.template >> gsl_sf.cc



# (int, int, double) to double

export octave_name=legendre_Plm
export    funcname=gsl_sf_legendre_Plm
cat << \EOF > docstring.txt
These routines compute the associated Legendre polynomial P_l^m(x) 
for m >= 0, l >= m, |x| <= 1.
EOF
./replace_template.sh int_int_double_to_double.cc.template >> gsl_sf.cc


export octave_name=legendre_sphPlm
export    funcname=gsl_sf_legendre_sphPlm
cat << \EOF > docstring.txt
These routines compute the normalized associated Legendre polynomial
$\sqrt{(2l+1)/(4\pi)} \sqrt{(l-m)!/(l+m)!} P_l^m(x)$ suitable for use
in spherical harmonics. The parameters must satisfy m >= 0, l >= m,
|x| <= 1. Theses routines avoid the overflows that occur for the
standard normalization of P_l^m(x).
EOF
./replace_template.sh int_int_double_to_double.cc.template >> gsl_sf.cc
