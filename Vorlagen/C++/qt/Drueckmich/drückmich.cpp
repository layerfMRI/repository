

// Knopf mit  Funktion: jetzt selbst-definierte Aktion.
//
// erst mit moc drueber: /usr/share/qt3/bin/moc -o drückmich.moc drückmich.cpp

#include <qapplication.h>
#include <qpushbutton.h>
#include <qobject.h>

class MyWidget : public QWidget
{
Q_OBJECT;

public:
  MyWidget(void);
public slots:
  void autsch(void);
private:
  QPushButton *ende;
}; 
MyWidget::MyWidget(void)
{
  ende = new QPushButton("Drueck mich!",this);
  ende->setGeometry(10,10,200,40);
  
  QObject::connect(ende,SIGNAL(clicked()),this ,SLOT(autsch()));
}

void MyWidget::autsch() {
  ende->setText("Aua, nicht so grob !");
  QObject::connect(ende,SIGNAL(clicked()),qApp ,SLOT(quit()));
}


#include "drückmich.moc"
int main(int argc,char **argv)
{
  
  QApplication app(argc,argv);
 
  MyWidget *mywidget  = new MyWidget();
  
  mywidget->resize(220,100);
  mywidget->show();
  app.setMainWidget(mywidget);
  return app.exec();
}
