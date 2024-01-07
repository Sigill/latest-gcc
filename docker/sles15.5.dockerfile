FROM registry.suse.com/suse/sle15:15.5

RUN zypper -n install -y --no-recommends ccache gcc12 gcc12-c++ rpm-build
RUN zypper -n install -y --no-recommends libelf-devel mpfr-devel mpc-devel flex makeinfo
