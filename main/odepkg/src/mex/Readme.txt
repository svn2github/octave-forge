# Note: The source files of this directory are obsolete and are not
#   needed anymore to run the Hairer-Wanner solvers in Octave. The
#   interface functions for the most of these solvers have been ported
#   to the C++DLD interface. Some of them (dopri5, dop853 and odex -
#   all being non-stiff ODE-solvers) are obsolete because similar
#   solvers have been implemented. 
#
#   However, these source files have not been removed, the mex-files
#   can still be created but *NOTE* that the sources are not supported
#   anymore. To compile these files call 'make all' from the command
#   line. For cleanup call 'make clean'. Put the *.mex files that are
#   created after calling 'make all' and also put the *.m files of
#   this directory into another directory where they can be found from
#   Octave or add this path to the function search-path.
#
# 2007.11.28, treichl@users.sourceforge.net
