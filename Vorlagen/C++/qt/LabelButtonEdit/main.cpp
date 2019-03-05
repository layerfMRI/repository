//compilieren mit: 
//qmake -projekt
//qmake
//make
// ./LabelButton

#include <qapplication.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qpushbutton.h>
#include <qfont.h>
#include <qslider.h>
#include <qlcdnumber.h>
#include <qtextedit.h>

class MyWidget : public QWidget
{

public:
  MyWidget(void);
;
  
}; 

MyWidget::MyWidget(void)
{
	//Text, der nicht weiter verarbeitet werden kann
  QLabel* qlab = new QLabel(this);  // Label
  qlab->setText( "first line\nsecond line" );
  qlab->setGeometry(20,20,100,30); //1. Abstand von ganz links, 2. Abstand von oben, 3. Länge, 4. Höhe
  //Beschreibbare Fläche mit Text, der nicht weiter verarbeitet werden kann
  QLineEdit* ledit = new QLineEdit(this);  // Text-Feld
  ledit->setText( "Beschreibbare Zeie ..." );
  ledit->setGeometry(125,20,150,30);
  
  //Qiut Button

    QPushButton *quit = new QPushButton("Quit", this);
    quit->setGeometry(300,20,180,30);
    // verbindet des Klicken auch den button mit schließe des Ramens
    QObject::connect( quit, SIGNAL(clicked()), qApp, SLOT(quit())); //qApp ist ein globaler Zeiger auf QApplication
 

	//Slider & Ausgabe muss in der klasse gemacht werden, weil sonst des Horizontal nicht erkannt wird
	QLCDNumber *lcd  = new QLCDNumber( 2, this, "lcd" ); // die 2 steht für zwei Ziffern
	lcd->setGeometry(20,80,460,30);
	QSlider * slider = new QSlider( Horizontal, this, "slider" );
	slider->setGeometry(20,120,460,30);
    slider->setRange( 0, 99 );
    slider->setValue( 0 );
    connect( slider, SIGNAL(valueChanged(int)), lcd, SLOT(display(int)) );
    
  //noch mal text, der weiterverarbeitet werden kann
  QTextEdit* qtxt = new QTextEdit(this);  
  qtxt->setText( " Diesne Text\n kann man weiter-\n verwenden..." );
  qtxt->setGeometry(10,160,280,70);
  
}


int main(int argc,char **argv)
{
  
  QApplication app(argc,argv);
 
  MyWidget *mywidget  = new MyWidget();
  
  mywidget->resize(500,250);
  mywidget->show();
  app.setMainWidget(mywidget);
  return app.exec();
}

