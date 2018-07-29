First configure (depending on platforms) using one of:

    ./homebrew_configure.sh
    ./linux_configure.sh

Then change to the build directory and build:

    cd build
    make

For Mac only, built the user docs:

    make userdoc

Then install everywhere:

    make install

Then again for Mac only, build the idlwave catalogs:

    make idlwave_catalog

This will create an installation containing:

  - IDL source
  - DLMs built for the given platform
  - user API docs (Mac only)
  - idlwave catalogs (Mac only)

Next, take the three installations (Mac, Linux, and Windows) and combine them into a single installation tree:

    $ cp -r mglib-mac/ mglib
    $ cp -r mglib-linux/ mglib
    $ cp -r mglib-windows/ mglib

Then, create the IPM with:

    IDL> ipm, /create, 'mglib'
