Name: %{_name}
Version: %{_version}
Release: %{_release}
Summary: The Low Level Virtual Machine
Group: Development/Libraries
License: GPLv3+ and GPLv3+ with exceptions and GPLv2+ with exceptions and LGPLv2+ and BSD
Requires: glibc-devel binutils

%description
GCC, the GNU Compiler Collection.


%install
make -C "%{_sourcedir}" DESTDIR="%{buildroot}" install-strip


%files
%defattr(-,root,root,-)
%{_prefix}
