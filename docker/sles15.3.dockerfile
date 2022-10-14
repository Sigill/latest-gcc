FROM registry.suse.com/suse/sle15:15.3

RUN zypper -n install -y --no-recommends ccache gcc11 gcc11-c++ rpm-build
RUN zypper -n install -y --no-recommends libelf-devel mpfr-devel mpc-devel flex makeinfo
