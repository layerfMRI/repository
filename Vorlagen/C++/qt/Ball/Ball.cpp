#include <qapplication.h>
#include <qpainter.h>
#include <qpixmap.h>
#include <qwidget.h>
#include <iostream>
#include <cmath>
#include <qtimer.h>
#include <cstdlib>
#include <vector>  // vector headers
#include <iostream>
using namespace std;

class Ball {
private:
  QPoint ballpos;
  QPoint ballveloc;
  int ballradius;
public:
  Ball();
  Ball(const QPoint &);
  virtual void travel(double time, int w, int h);
  void paint(QPainter &painter) const;

};

Ball::Ball()
{
  ballpos.setX(200);
  ballpos.setY(200);
  ballveloc.setX( rand()%20-10);
  ballveloc.setY( rand()%20-10);
  ballradius = 10;
}

Ball::Ball(const QPoint & p) : ballpos(p) 
{

  ballveloc.setX( rand()%20-10);
  ballveloc.setY( rand()%20-10);
  ballradius = 10;
}

void Ball::paint(QPainter &painter) const 
{
  painter.drawEllipse( ballpos.x()-ballradius, 
                 ballpos.y()-ballradius, ballradius, ballradius );
}

void Ball::travel(double time, int w, int h) {
  // Move the ball for the specified number of time units.
  // The ball is restricted to the specified rectangle.
  // Note:  The ball won't move at all if the width or height
  // of the rectangle is smaller than the ball's diameter.
  
  /* Don't do anything if the rectangle is too small. */

  int xmax = w;
  int ymax = h;
  int xmin = 0;
  int ymin = 0;

  int x = ballpos.x();
  int y = ballpos.y();

  int radius = ballradius;

  if (xmax - xmin < 2*radius || ymax - ymin < 2*radius)
    return;
  
  /* First, if the ball has gotten outside its rectangle, move it
     back.  (This will only happen if the rectagnle was changed
     by calling the setLimits() method or if the position of 
     the ball was changed by calling the setLocation() method.)
  */
  
  if (x-radius < xmin)
    x = xmin + radius;
  else if (x+radius > xmax)
    x = xmax - radius;
  if (y - radius < ymin)
    y = ymin + radius;
  else if (y + radius > ymax)
    y = ymax - radius;
  
  /* Compute the new position, possibly outside the rectangle. */
  
  double dx = ballveloc.x();
  double dy = ballveloc.y();

  double newx = x + dx*time;
  double newy = y + dy*time;
      
      /* If the new position lies beyond one of the sides of the rectangle,
         "reflect" the new point through the side of the rectangle, so it
         lies within the rectangle. */
      
  if (newy < ymin + radius) {
    newy = 2*(ymin+radius) - newy;
    dy = fabs(dy);
  }
  else if (newy > ymax - radius) {
    newy = 2*(ymax-radius) - newy;
    dy = -fabs(dy);
  }
  if (newx < xmin + radius) {
    newx = 2*(xmin+radius) - newx;
    dx = fabs(dx);
  }
  else if (newx > xmax - radius) {
    newx = 2*(xmax-radius) - newx;
    dx = -fabs(dx);
  }
  ballveloc.setX((int)dx);
  ballveloc.setY((int)dy);
  /* We have the new values for x and y. */
  ballpos.setX((int)newx);
  ballpos.setY((int)newy);
} // end travel()

// Das Hauptwidget
class BallAnim : public QWidget
{
    Q_OBJECT

public:
  BallAnim();

protected:
  virtual void paintEvent( QPaintEvent* );
  virtual void resizeEvent( QResizeEvent* );
  virtual void reDraw(  );

public slots:
virtual void timeout(  ); // slot for timer

private:

  Ball* vb;
  QColor bgcol;
  QPixmap buffer;
};

// Konstruktor 
BallAnim::BallAnim() : bgcol(yellow) 
{
  setBackgroundColor( bgcol );
  vb = new Ball();
  // create timer
  QTimer *internalTimer = new QTimer( this ); // create internal timer
  connect( internalTimer, SIGNAL(timeout()), this, SLOT(timeout()) ); // connect timer signal
  internalTimer->start( 20 );               // emit signal every 20 ms
}

// 
void BallAnim::timeout()  // action method invoked by timer
{
  int w = width();
  int h = height();
  vb->travel( 1., w, h ); // move the ball
  reDraw();               
}

// wird aufgerufen, wenn sich das Fenster neu zeichnen soll
void BallAnim::paintEvent( QPaintEvent* event )
{
  reDraw();
}

// 
void BallAnim::reDraw( )
{
  
  buffer.fill( bgcol );           //  füllen
  QPainter bufferpainter;
  bufferpainter.begin( &buffer, this );
  bufferpainter.setBrush( red );
  bufferpainter.setPen( red );

  vb->paint( bufferpainter );

  bufferpainter.end();
  // Der Puffer wird ins Fenster kopiert.
  bitBlt( this, 0, 0, &buffer );
}

// wird aufgerufen, wenn die Größe des Fensters verändert wird
void BallAnim::resizeEvent( QResizeEvent* event )
{
   QPixmap save( buffer );         // temporärer Puffer
   buffer.resize( event->size() ); // neue Größe
   buffer.fill( bgcol );           //  füllen
   bitBlt( &buffer, 0, 0, &save ); // temporären Puffer reinkopieren
}

#include "BallAnim1.moc"
int main( int argc, char **argv )
{
  QApplication myapp( argc, argv );

  BallAnim* mywidget = new BallAni();
  mywidget->setGeometry( 50, 50, 400, 400 );
  
  myapp.setMainWidget( mywidget );
  mywidget->show();
  return myapp.exec();
}

