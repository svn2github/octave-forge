# This file was created automatically by SWIG 1.3.27.
# Don't modify this file, modify the SWIG interface instead.

import _xraylib

# This file is compatible with both classic and new-style classes.
def _swig_setattr_nondynamic(self,class_type,name,value,static=1):
    if (name == "this"):
        if isinstance(value, class_type):
            self.__dict__[name] = value.this
            if hasattr(value,"thisown"): self.__dict__["thisown"] = value.thisown
            del value.thisown
            return
    method = class_type.__swig_setmethods__.get(name,None)
    if method: return method(self,value)
    if (not static) or hasattr(self,name) or (name == "thisown"):
        self.__dict__[name] = value
    else:
        raise AttributeError("You cannot add attributes to %s" % self)

def _swig_setattr(self,class_type,name,value):
    return _swig_setattr_nondynamic(self,class_type,name,value,0)

def _swig_getattr(self,class_type,name):
    method = class_type.__swig_getmethods__.get(name,None)
    if method: return method(self)
    raise AttributeError,name

import types
try:
    _object = types.ObjectType
    _newclass = 1
except AttributeError:
    class _object : pass
    _newclass = 0
del types


PI = _xraylib.PI
AVOGNUM = _xraylib.AVOGNUM
KEV2ANGST = _xraylib.KEV2ANGST
MEC2 = _xraylib.MEC2
RE2 = _xraylib.RE2
KA_LINE = _xraylib.KA_LINE
KB_LINE = _xraylib.KB_LINE
LA_LINE = _xraylib.LA_LINE
LB_LINE = _xraylib.LB_LINE
F1_TRANS = _xraylib.F1_TRANS
F12_TRANS = _xraylib.F12_TRANS
F13_TRANS = _xraylib.F13_TRANS
FP13_TRANS = _xraylib.FP13_TRANS
F23_TRANS = _xraylib.F23_TRANS

XRayInit = _xraylib.XRayInit

SetHardExit = _xraylib.SetHardExit

SetExitStatus = _xraylib.SetExitStatus

GetExitStatus = _xraylib.GetExitStatus

AtomicWeight = _xraylib.AtomicWeight

CS_Total = _xraylib.CS_Total

CS_Photo = _xraylib.CS_Photo

CS_Rayl = _xraylib.CS_Rayl

CS_Compt = _xraylib.CS_Compt

CSb_Total = _xraylib.CSb_Total

CSb_Photo = _xraylib.CSb_Photo

CSb_Rayl = _xraylib.CSb_Rayl

CSb_Compt = _xraylib.CSb_Compt

CS_KN = _xraylib.CS_KN

DCS_Thoms = _xraylib.DCS_Thoms

DCS_KN = _xraylib.DCS_KN

DCS_Rayl = _xraylib.DCS_Rayl

DCS_Compt = _xraylib.DCS_Compt

DCSb_Rayl = _xraylib.DCSb_Rayl

DCSb_Compt = _xraylib.DCSb_Compt

DCSP_Thoms = _xraylib.DCSP_Thoms

DCSP_KN = _xraylib.DCSP_KN

DCSP_Rayl = _xraylib.DCSP_Rayl

DCSP_Compt = _xraylib.DCSP_Compt

DCSPb_Rayl = _xraylib.DCSPb_Rayl

DCSPb_Compt = _xraylib.DCSPb_Compt

FF_Rayl = _xraylib.FF_Rayl

SF_Compt = _xraylib.SF_Compt

MomentTransf = _xraylib.MomentTransf

LineEnergy = _xraylib.LineEnergy

FluorYield = _xraylib.FluorYield

CosKronTransProb = _xraylib.CosKronTransProb

EdgeEnergy = _xraylib.EdgeEnergy

JumpFactor = _xraylib.JumpFactor

CS_FluorLine = _xraylib.CS_FluorLine

CSb_FluorLine = _xraylib.CSb_FluorLine

RadRate = _xraylib.RadRate

ComptonEnergy = _xraylib.ComptonEnergy
K_SHELL = _xraylib.K_SHELL
L1_SHELL = _xraylib.L1_SHELL
L2_SHELL = _xraylib.L2_SHELL
L3_SHELL = _xraylib.L3_SHELL
M1_SHELL = _xraylib.M1_SHELL
M2_SHELL = _xraylib.M2_SHELL
M3_SHELL = _xraylib.M3_SHELL
M4_SHELL = _xraylib.M4_SHELL
M5_SHELL = _xraylib.M5_SHELL
N1_SHELL = _xraylib.N1_SHELL
N2_SHELL = _xraylib.N2_SHELL
N3_SHELL = _xraylib.N3_SHELL
N4_SHELL = _xraylib.N4_SHELL
N5_SHELL = _xraylib.N5_SHELL
N6_SHELL = _xraylib.N6_SHELL
N7_SHELL = _xraylib.N7_SHELL
O1_SHELL = _xraylib.O1_SHELL
O2_SHELL = _xraylib.O2_SHELL
O3_SHELL = _xraylib.O3_SHELL
O4_SHELL = _xraylib.O4_SHELL
O5_SHELL = _xraylib.O5_SHELL
O6_SHELL = _xraylib.O6_SHELL
O7_SHELL = _xraylib.O7_SHELL
P1_SHELL = _xraylib.P1_SHELL
P2_SHELL = _xraylib.P2_SHELL
P3_SHELL = _xraylib.P3_SHELL
P4_SHELL = _xraylib.P4_SHELL
P5_SHELL = _xraylib.P5_SHELL
KL1_LINE = _xraylib.KL1_LINE
KL2_LINE = _xraylib.KL2_LINE
KL3_LINE = _xraylib.KL3_LINE
KM1_LINE = _xraylib.KM1_LINE
KM2_LINE = _xraylib.KM2_LINE
KM3_LINE = _xraylib.KM3_LINE
KM4_LINE = _xraylib.KM4_LINE
KM5_LINE = _xraylib.KM5_LINE
KN1_LINE = _xraylib.KN1_LINE
KN2_LINE = _xraylib.KN2_LINE
KN3_LINE = _xraylib.KN3_LINE
KN4_LINE = _xraylib.KN4_LINE
KN5_LINE = _xraylib.KN5_LINE
L1M1_LINE = _xraylib.L1M1_LINE
L1M2_LINE = _xraylib.L1M2_LINE
L1M3_LINE = _xraylib.L1M3_LINE
L1M4_LINE = _xraylib.L1M4_LINE
L1M5_LINE = _xraylib.L1M5_LINE
L1N1_LINE = _xraylib.L1N1_LINE
L1N2_LINE = _xraylib.L1N2_LINE
L1N3_LINE = _xraylib.L1N3_LINE
L1N4_LINE = _xraylib.L1N4_LINE
L1N5_LINE = _xraylib.L1N5_LINE
L1N6_LINE = _xraylib.L1N6_LINE
L1N7_LINE = _xraylib.L1N7_LINE
L2M1_LINE = _xraylib.L2M1_LINE
L2M2_LINE = _xraylib.L2M2_LINE
L2M3_LINE = _xraylib.L2M3_LINE
L2M4_LINE = _xraylib.L2M4_LINE
L2M5_LINE = _xraylib.L2M5_LINE
L2N1_LINE = _xraylib.L2N1_LINE
L2N2_LINE = _xraylib.L2N2_LINE
L2N3_LINE = _xraylib.L2N3_LINE
L2N4_LINE = _xraylib.L2N4_LINE
L2N5_LINE = _xraylib.L2N5_LINE
L2N6_LINE = _xraylib.L2N6_LINE
L2N7_LINE = _xraylib.L2N7_LINE
L3M1_LINE = _xraylib.L3M1_LINE
L3M2_LINE = _xraylib.L3M2_LINE
L3M3_LINE = _xraylib.L3M3_LINE
L3M4_LINE = _xraylib.L3M4_LINE
L3M5_LINE = _xraylib.L3M5_LINE
L3N1_LINE = _xraylib.L3N1_LINE
L3N2_LINE = _xraylib.L3N2_LINE
L3N3_LINE = _xraylib.L3N3_LINE
L3N4_LINE = _xraylib.L3N4_LINE
L3N5_LINE = _xraylib.L3N5_LINE
L3N6_LINE = _xraylib.L3N6_LINE
L3N7_LINE = _xraylib.L3N7_LINE


