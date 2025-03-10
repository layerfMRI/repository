// Ein einfaches Qt-Programm, das nur einen beschrifteten Knopf zeigt.
// Compiler-Aufruf:  g++ -I$QTDIR/include -g -o qthello1 qthello1.cpp -L$QTDIR/lib -lqt-mt

#include <qapplication.h>
#include <qpushbutton.h>
int main(int argc,char **argv)
{
  QApplication app(argc,argv); // Dieses Objekt braucht man fuer jedes GUI-Programm.

  QPushButton *hello = new QPushButton("Hello I'm Qt!",0);  // Ein Knopf (noch ohne Funktion)
  hello->resize(100,30);        // Groesse von Hand bestimmen
  hello->show();                // Sichtbar-machen des Haupt-Widget
  app.setMainWidget(hello);     // Jedes GUI-Programm braucht ein Haupt-Widget
  return app.exec();            // Hier beginnt die Event-Schleife
}
