#include once "../fb-game.bi"

'' A set of simple macros to do color blending
type as ulong color_t

#define _R_( _c_ ) ( culng( _c_ ) shr 16 and 255 )
#define _G_( _c_ ) ( culng( _c_ ) shr  8 and 255 )
#define _B_( _c_ ) ( culng( _c_ ) and 255 )
#define _A_( _c_ ) ( culng( _c_ ) shr 24 )

#define mix( _c1_, _c2_, _x_ ) ( ( cubyte( _c2_ ) - cubyte( _c1_ ) ) * _x_ + cubyte( _c1_ ) )
#define clerp( _c1_, _c2_, _x_ ) ( rgba( _
  mix( _R_( _c1_ ), _R_( _c2_ ), _x_ ), _
  mix( _G_( _c1_ ), _G_( _c2_ ), _x_ ), _
  mix( _B_( _c1_ ), _B_( _c2_ ), _x_ ), _
  mix( _A_( _c1_ ), _A_( _c2_ ), _x_ ) ) )

#define clamp( v, x, y ) ( iif( v < x, x, iif( v > y, y, v ) ) )

'' Just creates a nice background
function createBackground( _
    c1 as color_t, c2 as color_t, w as integer, h as integer ) as Fb.Image ptr
  
  dim as single _
    centerX = w / 2, _
    centerY = h / 2, _
    maxValue = sqr( centerX ^ 2 + centerY ^ 2 )
  
  var s = imageCreate( w, h )
  
  for y as integer = 0 to h - 1
    for x as integer = 0 to w - 1
      dim as single _
        v = sqr( ( centerX - x ) ^ 2 + ( centerY - y ) ^ 2 ) / ( maxValue + 1 )
      
      pset s, ( x, y ), clerp( c1, c2, v )
    next
  next
  
  return( s )
end function

function rndColor() as color_t
  return( rnd() * &hffffff )
end function

type Rectangle
  as long x1, y1, x2, y2
  as color_t c
end type

sub drawRect( byref r as Rectangle )
  line( r.x1, r.y1 ) - ( r.x2, r.y2 ), r.c, bf
end sub

sub add( rects() as Rectangle, r as Rectangle, byref count as integer )
  redim preserve rects( lbound( rects ) to ubound( rects ) + 1 )
  rects( ubound( rects ) ) = r
  count += 1
end sub

/'
  Test code
'/ 
using FbGame

dim as integer _
  w = 800, h = 600

screenRes( w, h, 32 )

var back = createBackground( _
  rgba( 252, 252, 252, 255 ), _
  rgba( 191, 191, 191, 255 ), _
  800, 600 )

var mouse = MouseInput()

dim as boolean drawing = false

dim as Fb.Event e

dim as integer rectCount = 0
dim as Rectangle rectangles( any )

do
  '' Poll events
  do while( screenEvent( @e ) )
    mouse.onEvent( @e )
  loop
  
  with mouse
    if( .drag( Fb.BUTTON_LEFT ) ) then
      drawing = true
    end if
    
    if( .drop( Fb.BUTTON_LEFT ) ) then
      add( rectangles(), type <Rectangle>( _
        .startX, .startY, clamp( .X, 0, w - 1 ), clamp( .Y, 0, h - 1 ), rndColor() ), rectCount )
      
      drawing = false
    end if
  end with
  
  '' Render frame
  screenLock()
    cls()
    put( 0, 0 ), back, pset
    
    for i as integer = 0 to rectCount - 1
      drawRect( rectangles( i ) )
    next
    
    if( drawing ) then
      line( mouse.startX, mouse.startY ) - _
        ( clamp( mouse.X, 0, w - 1 ), clamp( mouse.Y, 0, h - 1 ) ), rgb( 0, 0, 0 ), b
    end if
  screenUnlock()
  
  sleep( 1, 1 )
loop until( e.type = Fb.EVENT_WINDOW_CLOSE )

imageDestroy( back )
