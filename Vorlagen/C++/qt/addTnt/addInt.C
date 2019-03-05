
// erst mit moc drueber $QTDIR/bin/moc -o addInt.moc addInt.C
#include <qapplication.h>
#include <qlineedit.h>
#include <qlabel.h>
#include <qpushbutton.h>
#include <qlayout.h>
#include <qstring.h>
class MyWidget : public QWidget
{
  Q_OBJECT;
public:
  MyWidget(void);
public slots:
  void addint(void);
private:
  QPushButton *add;
  QLineEdit* num1 ;
  QLineEdit* num2 ;
  QLineEdit* num3 ;
}; 
MyWidget::MyWidget(void)
{
  num1 = new QLineEdit(this);  // Text-Feld
  num1->setText( "0" );
  num2 = new QLineEdit(this);  // Text-Feld
  num2->setText( "0" );
  num3 = new QLineEdit(this);  // Text-Feld
  num3->setText( "0" );
  QPushButton *qpb = new QPushButton("Add",this); // Knopf
  QLabel *qlab = new QLabel("Result",this); // label
  QVBoxLayout* layout = new QVBoxLayout(this);
  layout->addWidget(num1);
  layout->addWidget(qpb);
  layout->addWidget(num2);
  layout->addWidget(qlab);
  layout->addWidget(num3);
  // 
  QObject::connect(qpb,SIGNAL(clicked()),this,SLOT(addint())); // button => addint
  QObject::connect(num1,SIGNAL(returnPressed()),this,SLOT(addint())); // textfield => addint
  QObject::connect(num2,SIGNAL(returnPressed()),this,SLOT(addint()));
}
void MyWidget::addint() { // add 2 integers
  int v1 = (num1->text()).toInt(); // QString ==> int
  int v2 = (num2->text()).toInt();
  int v3 = v1 + v2;
  QString qs;
  qs.setNum(v3);  // int ==> QString
  num3->setText(qs);
}
#include "addInt.moc"

int main(int argc,char** argv)
{
  QApplication app(argc,argv);
  QWidget* mywidget = new MyWidget();
  mywidget->resize(120,130);
  app.setMainWidget(mywidget);
  mywidget->show();
  return app.exec();
}

