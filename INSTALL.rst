Building
--------

Use `CMake <http://www.cmake.org>`_ to configure mglib before building. For
example, for a basic install, you would do the following from the root
directory of mglib::

  cmake -DCMAKE_INSTALL_PREFIX=/path/to/install .

There is a more complete example configuration (using builds in */usr/local*)
command in *example_configure.sh* which specifies some optional libraries that
cause DLMs that depend on them to be built.

After configuration, build mglib with::

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
