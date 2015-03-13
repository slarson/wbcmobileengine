# Introduction #

> logic -> this is to be done by the tilerender class

> initialize:
> > allocate the first 3 resolutions -> 1, 4, 8 : have to generate 13 urls, 13 tile groups
> > allocateAll(2)


> from this point, allocate is called whenever the tile DRAW depth is within 1 (?)
> allocateByResRowCol


> cull cache:

> need to write function: pass in ofxvec3 position of camera (or arbitrary to test) and shape -> sphere?

> recursively traverse through all allocated tiles
> > if centroid within frustum,
> > > set InCacheFrustrum (if not already)


> if centroid not within frustum,
> > set inCacheFrustum = false



> cull view:

> need to write function passing ofxvec3 camera position and ... frustum matrix?

> recursively traverse through all allocated tiles

> if tile centroid is within frustum
> > set inViewFrustum = true
> > > ask children


> tile centroid not in view frustum
> > ask children if they're in view


> if any children in view frustum, set this.inViewFrustm = true as well

> if no children are in view frustum, set this.inviewFrustum = false


> draw view:

> need to write function passing ofxvec3 camera position?

> if this.inviewfrustum

> check distance from centroid to camera position

> if distance is small ie the current tile would be blurry

> then draw children

> else distance is not small (ie the current tile is close enough to have multiple pixels per texel)

> "this tile should draw"
> does this tile have data?

> yes: previous download request passed and image loaded
> > draw me.


> no: no download request has been sent yet
> > send download request (with distance priority)
> > set downloadrequest sent = true


> allocate children (generates their TilegroupID and filename)

> draw place holder