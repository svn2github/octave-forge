homedir = pwd ();
develdir = fileparts (which ("makefile_ident"));
srcdir = [develdir, "/../src"];
cd (srcdir);

## preprocess the input-output data
mkoctfile IB01AD.f IB01MD.f IB01ND.f IB01OD.f IB01MY.f \
          MB04OD.f MB03UD.f MB04ID.f MA02AD.f MB03OD.f \
          MB04IY.f IB01OY.f MA02ED.f MA02FD.f MB04OY.f

## estimating system matrices, Kalman gain, and covariances
mkoctfile IB01BD.f IB01PD.f MA02AD.f SB02MT.f SB02RD.f \
          SB02ND.f MB02UD.f MA02ED.f IB01PY.f MB03OD.f \
          MB02QY.f IB01PX.f SB02MS.f SB02RU.f SB02SD.f \
          MB01RU.f SB02QD.f SB02MV.f SB02MW.f SB02MR.f \
          MB02PD.f MB01SD.f MB04KD.f MB03UD.f MB04OD.f \
          MB04OY.f MB01VD.f select.f MB01UD.f SB03SY.f \
          MB01RX.f SB03MX.f SB03SX.f MB01RY.f SB03QY.f \
          SB03QX.f SB03MY.f SB04PX.f SB03MV.f SB03MW.f

## estimating the initial state
mkoctfile IB01CD.f TB01WD.f IB01RD.f IB01QD.f select.f \
          MB01TD.f MA02AD.f MB04OD.f MB04OY.f MB02UD.f \
          MB03UD.f MB01SD.f

## fit state-space model to frequency response data
mkoctfile slsb10yd.cc \
          SB10YD.f DG01MD.f AB04MD.f SB10ZP.f AB07ND.f \
          MC01PD.f TD04AD.f TD03AY.f TB01PD.f TB01XD.f \
          AB07MD.f TB01UD.f TB01ID.f MB01PD.f MB03OY.f \
          MB01QD.f

system ("rm *.o");
cd (homedir);

