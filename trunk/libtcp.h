    * /*********************************************************/
    * /* Pour toute question, tout problème ou toute question, */
    * /* laissez un commentaire sur le site ou contactez: */
    * /* superpa@caramail.com */
    * /*********************************************************/
    * #ifndef LIBTCP_H
    * #define LIBTCP_H
    *
    * // il y a de nombreux headers inutiles, mais ils sont la pour des raisons historiques
    * // en effet, cette librairie est extraite d'un application bien plus importante et plus complexe
    * #include <sys/socket.h> // pour les types de socket.
    * #include <netinet/in.h>
    * #include <sys/types.h>
    * #include <string.h>
    * #include <netdb.h> // pour la structure hostent.
    * #include <errno.h>
    * #include <unistd.h>
    * #include <netinet/tcp.h>
    * #include <arpa/inet.h>
    * #include <stdio.h>
    * #include <stdlib.h>
    * #include <termios.h>
    * #include <signal.h>
    * #include <fcntl.h>
    * #include <iostream.h>
    * #include <arpa/inet.h>
    * #include <varargs.h>
    * #include <stdarg.h>
    * #include <time.h>
    *
    * /////////////////////////////////////////////////////////////////////////////////////////
    * // Classe d'exception
    * class error
    * {
    * public:
    * char *msg,*type;
    * int num;
    *
    * static const int UNKNOWNERROR = -1;
    * error(char *m = "Erreur inconnue",int n = UNKNOWNERROR,char *t = "Erreur classique");
    * error(error&);
    * virtual ~error();
    * };
    *
    * /////////////////////////////////////////////////////////////////////////////////////////
    * // CLASSE SOCKET
    * // ============
    * class socket
    * {
    * protected:
    * int hs; // handle de la socket
    * int port;
    * struct hostent *infoshost;
    *
    * static int szsockaddr_in;
    *
    * public:
    * struct in_addr adip;
    * struct sockaddr_in adsocket;
    *
    * // get et set
    * void setport(int p) { port = p; }
    * void seths(int h) { hs = h; }
    *
    * int geths() { return hs; }
    * int getport() { return port; }
    * char *getadip() { return inet_ntoa(adip); }
    *
    * // contructeurs et destructeur
    * socket();
    * socket(char *name,int p,int dom = AF_INET,int type = SOCK_STREAM,int protocol = IPPROTO_TCP);
    * socket(class socket& s);
    * virtual ~socket();
    *
    * // creation
    * void create();
    *
    * // methodes utiles
    * int getlocalinfos(char *);
    * void getAdEtPort();
    * class socket& operator=(class socket&);
    * int getpeername();
    *
    * int msgrcv(char *data,int nbmaxcar,int flag = 0);
    * int msgsnd(char *data,int nbmaxcar,int flag = 0);
    * };
    *
    * /////////////////////////////////////////////////////////////////////////////////////////
    * // CLASSE SOCKETSERVER
    * // ===================
    * class socketserver : public socket
    * {
    * protected:
    * public:
    * socketserver() : socket() {};
    * socketserver(char *name,int p,int dom = AF_INET,int type = SOCK_STREAM,int protocol = IPPROTO_TCP);
    * socketserver(socketserver&);
    *
    * // methodes
    * void bind();
    * void listen();
    * void accept(class socket& s);
    * };
    *
    * /////////////////////////////////////////////////////////////////////////////////////////
    * // CLASSE SOCKETCLIENT
    * // ===================
    * class socketclient : public socket
    * {
    * protected:
    * public:
    * socketclient() : socket() {};
    * socketclient(char *name,int p,int dom = AF_INET,int type = SOCK_STREAM,int protocol = IPPROTO_TCP);
    * socketclient(socketclient& s) : socket(s) {};
    *
    * // methodes
    * void connect();
    * };
    *
    * #endif
*


