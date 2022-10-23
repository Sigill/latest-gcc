# Latest GCC

Scripts to build recent versions of GCC for various Linux distributions.

## Debian 11

```sh
git clone --depth 1 -b release/gcc-x.y.z --single-branch git://gcc.gnu.org/git/gcc.git gcc-x.y.z

# Edit buld-debian11.sh accordingly.

./build-debian11.sh
```

## SLES 15.x

```sh
git clone --depth 1 -b release/gcc-x.y.z --single-branch git://gcc.gnu.org/git/gcc.git gcc-x.y.z

# Edit buld-sles15.x.sh accordingly.

./build-sles15.x.sh
```

## License

The content of this repository is released under the terms of the BSD Zero Clause License. See the LICENSE.txt file for more details.
