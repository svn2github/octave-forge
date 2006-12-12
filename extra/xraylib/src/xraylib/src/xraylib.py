# This file was created automatically by SWIG.
# Don't modify this file, modify the SWIG interface instead.
# This file is compatible with both classic and new-style classes.
import _xraylib
def _swig_setattr(self,class_type,name,value):
    if (name == "this"):
        if isinstance(value, class_type):
            self.__dict__[name] = value.this
            if hasattr(value,"thisown"): self.__dict__["thisown"] = value.thisown
            del value.thisown
            return
    method = class_type.__swig_setmethods__.get(name,None)
    if method: return method(self,value)
    self.__dict__[name] = value

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


ZMAX = _xraylib.ZMAX
PI = _xraylib.PI
AVOGNUM = _xraylib.AVOGNUM
KEV2ANGST = _xraylib.KEV2ANGST
MEC2 = _xraylib.MEC2
RE2 = _xraylib.RE2
K_SHELL = _xraylib.K_SHELL
L1_SHELL = _xraylib.L1_SHELL
L2_SHELL = _xraylib.L2_SHELL
L3_SHELL = _xraylib.L3_SHELL
M1_SHELL = _xraylib.M1_SHELL
M2_SHELL = _xraylib.M2_SHELL
M3_SHELL = _xraylib.M3_SHELL
M4_SHELL = _xraylib.M4_SHELL
M5_SHELL = _xraylib.M5_SHELL
KA_LINE = _xraylib.KA_LINE
KB_LINE = _xraylib.KB_LINE
LA_LINE = _xraylib.LA_LINE
LB_LINE = _xraylib.LB_LINE
LG_LINE = _xraylib.LG_LINE
LB2_LINE = _xraylib.LB2_LINE
MA_LINE = _xraylib.MA_LINE
F1_TRANS = _xraylib.F1_TRANS
F12_TRANS = _xraylib.F12_TRANS
F13_TRANS = _xraylib.F13_TRANS
FP13_TRANS = _xraylib.FP13_TRANS
F23_TRANS = _xraylib.F23_TRANS
XRayInit = _xraylib.XRayInit

AtomicWeight = _xraylib.AtomicWeight

CS_Total = _xraylib.CS_Total

CS_Photo = _xraylib.CS_Photo

CS_Rayl = _xraylib.CS_Rayl

CS_Compt = _xraylib.CS_Compt

DCS_Thoms = _xraylib.DCS_Thoms

DCS_KN = _xraylib.DCS_KN

DCS_Rayl = _xraylib.DCS_Rayl

DCS_Compt = _xraylib.DCS_Compt

DCSP_Thoms = _xraylib.DCSP_Thoms

DCSP_KN = _xraylib.DCSP_KN

DCSP_Rayl = _xraylib.DCSP_Rayl

DCSP_Compt = _xraylib.DCSP_Compt

FF_Rayl = _xraylib.FF_Rayl

SF_Compt = _xraylib.SF_Compt

MomentTransf = _xraylib.MomentTransf

LineEnergy = _xraylib.LineEnergy

FluorYield = _xraylib.FluorYield

CosKronTransProb = _xraylib.CosKronTransProb

EdgeEnergy = _xraylib.EdgeEnergy

JumpFactor = _xraylib.JumpFactor

CS_FluorLine = _xraylib.CS_FluorLine

RadRate = _xraylib.RadRate


