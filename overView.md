_This will serve as the core for WBC mobile applications_
---
Built on openframeworks for portability.

  * 3D engine - openGL ES2.0 with 1.1 fallback
  * 3D curve generation (msainterpolator)
  * 2D gui with xml definitions - ofxgui with customizations
  * Multiresolution tilerenderer - loosely based on stackvis (completely rewritten)
  * XML parsing (wrapped TinyXML)
  * Threaded downloading and event management (POCO)
  * Central data management (WBCexchange)

## Engine ##
  * Ambient and directional lighting
  * Perspective and Orthogonal camera (from stackvis)
  * CPU object culling (oolong engine)
  * Render mesh, tiles, traces

  * ### Mesh ###
    * Load model into scene (3ds, stl, obj, custom)
    * Change render mode (point, wireframe, solid, transparent, future:shaders)
    * Remove model from scene
    * Define clip plane (user clip planes in ES1.1, shader in ES2.0)
> _Optional: move model in 3D (not sure if this is needed)_

  * ### Curves ###
    * 2D/3D interpolation for arbitrary precision
    * linear and cubic interpolation methods
    * Add/Remove points to curve
    * Select/Manipulate points with touch

  * ### GUI ###
    * Define/load from XML
    * Animate control positions
    * Toggle subgroups (panels)
    * Controls available: panel, button, color slider, file list, knob, matrix, points, radar, scope, slider, switch, xy pad

## Tile renderer ##
  * Add tilegroup from URL
  * sites supported: zoomify(general), brainmaps.org, ABA, ccdb
  * recursive drawing
  * multiple slides per tile group (equiv. to dataset from stackviz)
  * support for multiple groups
  * exclusive threaded tile downloader (does not interfere with WBCexchange download priorities)


## Exchange (Data management) ##
  * Handles interaction with data sources and local stores
  * Populate list of data on brain-maps.org from local xml
  * Populate list of zoomify reconstructions from ccdb via local xml
  * Load zoomify data description from URL
  * exclusive threaded file downloader (does not interfere with tile renderer)
  * blocking downloader (pauses thread until file received)
  * Can parse:
    1. zoomify header (imageproperties.xml)
    1. ccdb traces (traces.xml)
    1. brainmaps tile list (slideslist)
    1. images