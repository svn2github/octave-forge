# XXX FIXME XXX while extra/NaN has NOINSTALL set, we need to resolve the
# dependencies between tsa and NaN by hand.
include ../../Makeconf

DEPENDS=flag_implicit_skip_nan.m flag_implicit_dimension.m sumskipnan.m covm.m

all:

install:
	$(INSTALL) -d $(MPATH)/NaN
	cd ../NaN && $(INSTALL_DATA) $(DEPENDS) $(MPATH)/NaN
