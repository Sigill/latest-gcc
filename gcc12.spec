# Build with rpmbuild -bb gcc12.spec --define "_sourcedir $PWD/root" --verbose
%define name gcc12
%define version 2.0
%define release 1

%define _binary_payload w4.gzdio

Name: %{name}
Version: %{version}
Release: %{release}
Summary: The Low Level Virtual Machine
Group: Development/Libraries
License: BSD

%description
The gcc package contains the GNU Compiler Collection version 12.


%install
mkdir -p %{buildroot}
cp -r %{_sourcedir}/opt %{buildroot}/


%files
%defattr(-,root,root,-)
/opt/gcc-12
%doc


%changelog
* Thu Sep 22 2022 <cyrille.faucheux@gmail.com>
- Release 12.2.0-1.
