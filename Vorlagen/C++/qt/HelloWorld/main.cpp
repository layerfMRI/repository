// Ein einfaches Qt-Programm, das nur einen beschrifteten Knopf zeigt.

//	complieren am Besten mit Makefile 
//	in Konsole eintippen:
//
//	qmake -project
//	qmake
//	make
//
// dann ist es ./"Name des Ordners" 



#include <qpushbutton.h>
#include <qapplication.h>


int main(int argc, char **argv)
{
    QApplication app(argc, argv);   // braucht man wohl für jedes GUI programm

    QPushButton *hello= new QPushButton( " Hallo Ich bin ein Fenster ! ", 0);
    hello->resize(200, 60); //Größe von Hand festlegen

    hello->show();         // sichtbarmachen des Fensters
    app.setMainWidget(hello); // beendet des Programm, wenn man Fenster schließt
    return app.exec(); //führt Event-schleife aus
}
