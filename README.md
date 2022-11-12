# Latest GCC

Scripts to build recent versions of GCC for various Linux distributions.

## SLES15.x/Debian 11

```sh
git clone --depth 1 -b releases/gcc-x.y.z --single-branch git://gcc.gnu.org/git/gcc.git gcc-x.y.z

./build-containerized.sh --env sles15.3|sles15.4|debian11 --source gcc-x.y.z -v x.y.z -j N
```

## License

The content of this repository is released under the terms of the BSD Zero Clause License. See the LICENSE.txt file for more details.
