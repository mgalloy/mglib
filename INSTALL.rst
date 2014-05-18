Building
--------

Use `CMake <http://www.cmake.org>`_ to configure mglib before building. For
example, for a basic install, you could do the following from the root
directory of mglib::

  cmake -DCMAKE_INSTALL_PREFIX=/path/to/install .

There are more complete example configuration commands in
*homebrew_configure.sh* (for OS X builds using homebrew to get dependencies),
*unix_configure.sh* (for basic unix configuration), and *simmple_configure.sh*
(which doesn't build any DLMs with dependencies) which specifies some optional
libraries that cause DLMs that depend on them to be built. These example configuration scripts build out-of-source, so change to the *build* directory before building::

  cd build

Then build mglib with::

  make

And install with::

  make install


Testing
-------

Running the unit tests requires `mgunit <https://github.com/mgalloy/mgunit>`_,
a unit testing framework for IDL. Download mgunit and place it in your IDL
path. To run the mglib unit tests, use the `unit` Makefile target::

  make unit


Generating documentation
------------------------

Generating the API documentation for mglib requires `IDLdoc
<https://github.com/mgalloy/idldoc>`_. Download IDLdoc and place it in your IDL
path. To generate the API documentation, use the `doc` or `userdoc` Makefile
targets::

  make doc
  make userdoc

The `doc` target generates documentation appropriate for developers or
contributors to mglib, while `userdoc` generates documentation appropriate for
users of mglib.
