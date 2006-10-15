%define name qhull
%define version 2003.1
%define release 1mdk
%define pack %{name}-%{version}
Summary: General dimension convex hull programs
Name: %{name}
Version: %{version}
Release: %{release}
License:  Redistributable
Group: System/Libraries
Source0: %{pack}.tar.gz
URL: http://www.geom.umn.edu/software/qhull/
BuildRoot: %{_tmppath}/%{name}-buildroot
Prefix: %{_prefix}

%description

Qhull is a general dimension convex hull program that reads a set
of points from stdin, and outputs the smallest convex set that contains
the points to stdout.  It also generates Delaunay triangulations, Voronoi
diagrams, furthest-site Voronoi diagrams, and halfspace intersections
about a point.

Rbox is a useful tool in generating input for Qhull; it generates
hypercubes, diamonds, cones, circles, simplices, spirals,
lattices, and random points.

Qhull produces graphical output for Geomview.  This helps with
understanding the output. <http://www.geomview.org>

%prep
%setup -n %{pack}
cd src
sed -e 's,^BINDIR *= .*$,BINDIR = '$RPM_BUILD_ROOT'%_bindir,' \
    -e 's,^MANDIR *= .*$,MANDIR = '$RPM_BUILD_ROOT'%_mandir/man1,' \
    -e 's,^CCOPTS1 *= .*$,CCOPTS1 = %optflags,' \
    Makefile.txt > Makefile
echo '
libqhull.so.'%{version}': $(OBJS)
	$(CC) -shared -Xlinker -soname -Xlinker $@ -o $@ $(OBJS)

libqhull.so: libqhull.so.'%{version}'
	'%__ln_s' -f $< $@
' >> Makefile

%build

cd src
make libqhull.so
export LD_LIBRARY_PATH=`pwd`
make

%install
%__rm -rf $RPM_BUILD_ROOT

%__mkdir_p $RPM_BUILD_ROOT%_bindir
%__mkdir_p $RPM_BUILD_ROOT%_libdir
%__mkdir_p $RPM_BUILD_ROOT%_mandir/man1
%__mkdir_p $RPM_BUILD_ROOT%_includedir/%{name}

cd src
make install
%__cp *.h $RPM_BUILD_ROOT%_includedir/%{name}
%__cp *.a libqhull.so* $RPM_BUILD_ROOT%_libdir


%clean
%__rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc Announce.txt
%doc REGISTER.txt
%doc COPYING.txt
%doc README.txt
%doc html
%_bindir/*
%_libdir/*
%_includedir/*
%_mandir/*

%changelog
* Wed Jun 16 2004 Laurent Mazet <mazet@crm.mot.com> 2003.1-1mdk
- Update to qhull new version

* Thu Sep 05 2002 Laurent Mazet <mazet@crm.mot.com> 2002.1-1mdk
- Update to qhull new version

* Thu May 30 2002 Laurent Mazet <mazet@crm.mot.com> 3.1-1mdk
- First package

# end of file
