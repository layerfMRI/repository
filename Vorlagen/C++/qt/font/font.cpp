

#include <qapplication.h>
#include <qpushbutton.h>
#include <qfont.h>


int main( int argc, char **argv )
{
    QApplication a( argc, argv );

    QPushButton quitB( "Quit", 0 );
    quitB.resize( 200, 35 ); //Länge, Breite
    quitB.setFont( QFont( "Times", 18, QFont::Bold ) );

    QObject::connect( &quitB, SIGNAL(clicked()), &a, SLOT(quit()) );

    a.setMainWidget( &quitB );
    quitB.show();
    return a.exec();
}


