#include once "../fb-game.bi"

type as ulong color_t

#define _R_( _c_ ) ( cubyte( culng( _c_ ) shr 16 and 255 ) )
#define _G_( _c_ ) ( cubyte( culng( _c_ ) shr  8 and 255 ) )
#define _B_( _c_ ) ( cubyte( culng( _c_ ) and 255 ) )
#define _A_( _c_ ) ( cubyte( culng( _c_ ) shr 24 ) )

#define mix( _c1_, _c2_, _x_ ) ( ( cubyte( _c2_ ) - cubyte( _c1_ ) ) * _x_ + cubyte( _c1_ ) )

#define clerp( _c1_, _c2_, _x_ ) ( rgba( _
  mix( _R_( _c1_ ), _R_( _c2_ ), _x_ ), _
  mix( _G_( _c1_ ), _G_( _c2_ ), _x_ ), _
  mix( _B_( _c1_ ), _B_( _c2_ ), _x_ ), _
  mix( _A_( _c1_ ), _A_( _c2_ ), _x_ ) ) )

#define clamp( v, x, y ) ( iif( v < x, x, iif( v > y, y, v ) ) )

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

/'
  Test code
'/
using FbGame

dim as integer w = 800, h = 600

screenRes( w, h, 32 )

var back = createBackground( _
  rgba( 252, 252, 252, 255 ), _
  rgba( 191, 191, 191, 255 ), _
  800, 600 )

var mouse = MouseInput()

dim as boolean toggle = false

dim as Fb.Event e

do
  '' Poll events
  do while( screenEvent( @e ) )
    mouse.onEvent( @e )
  loop
  
  dim as color_t _
    ballColor = rgba( 255, 0, 0, 255 ), _
    squareColor = iif( toggle, _
      rgba( 255, 255, 0, 255 ), _
      rgba( 0, 255, 0, 255 ) )
  
  if( mouse.held( Fb.BUTTON_LEFT ) ) then
    ballColor = rgba( 0, 0, 255, 255 )
  end if
  
  if( mouse.repeated( Fb.BUTTON_LEFT, 200.0d ) ) then
    toggle xor= true
  end if
  
  '' Render frame
  screenLock()
    put( 0, 0 ), back, pset
    
    dim as integer _
      mx = clamp( mouse.X, 0, w - 1 ), _
      my = clamp( mouse.Y, 0, h - 1 )
    
    circle( mx, my ), 25, ballColor, , , , f
    line( mx - 200 - 25, my - 25 ) - _
      ( mx - 200 + 25, my + 25 ), squareColor, bf
  screenUnlock()
  
  sleep( 1, 1 )
loop until( e.type = Fb.EVENT_WINDOW_CLOSE )

imageDestroy( back )
