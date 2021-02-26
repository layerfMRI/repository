#include <qapplication.h>
#include <qpainter.h>

class MyWidget : public QWidget
{
public:
  MyWidget();
protected:
  virtual void paintEvent(QPaintEvent*);
};

MyWidget::MyWidget()
{
  setBackgroundColor(white);
}

void MyWidget::paintEvent(QPaintEvent *e)
{

  QBrush b1( Qt::blue );
  QBrush b2( Qt::green, Qt::Dense6Pattern );          // green 12% fill
  QBrush b3( Qt::NoBrush );                           // void brush
  QBrush b4( Qt::CrossPattern );                      // black cross pattern

  QPainter *paint = new QPainter();
  paint->begin(this);
  paint->setPen( Qt::red );
  paint->setBrush( b1 );
  paint->drawRect( 10, 10, 200, 100 );
  paint->setBrush( b2 );
  paint->drawRoundRect( 10, 150, 200, 100, 20, 20 );
  paint->setBrush( b3 );
  paint->drawEllipse( 250, 10, 200, 100 );
  paint->setBrush( b4 );
  paint->drawPie( 250, 150, 200, 100, 45*16, 90*16 );//    paint->translate(20.0,40.0);
  paint->end();
}
//....
