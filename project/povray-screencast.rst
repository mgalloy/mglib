-------------------------------------------
POV-Ray destination for IDL Object Graphics
-------------------------------------------

Simple example
--------------

run the cow example::

    IDL> .run mggrpovray__define
    IDL> .continue

show code for POV-Ray destination


Goals
-----

There are two main goals for the POV-Ray destination:

#. create higher quality output of a standard object graphics scene

   nothing needs to be done; just use the MGgrPOVRay destination

#. create an easier to use interface to POV-Ray

   extra graphics classes provided to access POV-Ray functionality, they render normally when sent to a standard destination


Coverage
--------

The POV-Ray destination cannot handle all graphics atoms. Currently, it only supports the following classes:

#. `IDLgrView`
#. `IDLgrModel`
#. `IDLgrPolyline`
#. `IDLgrPolygon`
#. `IDLgrSurface`
#. `IDLgrText`

Also, only the most common properties of these classes are supported.
   
Advanced usage
--------------

The following classes can be used to access POV-Ray specific functionality:

#. `MGgrPOVRayFinish`
#. `MGgrPOVRayGrid`
#. `MGgrPOVRayLight`
#. `MGgrPOVRayPolygon`
#. `MGgrPOVRayTubes`
#. `MGgrPOVRayView`

Show examples of each one of these.


Misc
----

#. creating the final images requires an installation of POV-Ray
#. `MGgrPOVRayWindow`
#. `MG_XPOVRAY`

