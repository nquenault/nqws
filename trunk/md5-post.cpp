////////////////////////////////////////
//projet: Remote post md5 serveurhaksyn 
//site: http://serveurhaksyn.free.fr
//Author: 0x0syscall
//TeaM:   HaKSyN TeaM - Dev
////////////////////////////////////////

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

char syntax()
	{
	printf("\nRemote post md5 serveurhaksyn by 0x0syscall\n");
	printf("-----------------------------------------------\n");
	printf("=>Syntax : <./file> | (encrypter) -e <mot> | (decrypter) -d <hash>\n\n");
	return 0;
	}

int main(int argc, char **argv)
{
	if(argc < 3)
	{
	syntax();
	return 0;	
	}

	int mysocket;
	int mysocket2;
	int srv_connect;
	int sockaddr_long;

		struct sockaddr_in sockaddr_mysocket;
		sockaddr_long = sizeof(sockaddr_mysocket);
		sockaddr_mysocket.sin_family = AF_INET;
		sockaddr_mysocket.sin_addr.s_addr = inet_addr("212.27.63.116");
		sockaddr_mysocket.sin_port = htons(80);

		mysocket2 = socket(AF_INET, SOCK_STREAM, 0);
 			if(mysocket2 == -1)
 			perror("");

			srv_connect = connect(mysocket2, (struct sockaddr*)&sockaddr_mysocket, sockaddr_long);

	printf("\n+---------------------------------------------+\n");
	printf("+ Remote post md5 serveurhaksyn by 0x0syscall +\n");
	printf("+ HaKSyN TeaM - Dev                           +\n");
	printf("+---------------------------------------------+\n\n");
	
	if (srv_connect != -1)
 		{	

		printf("Connect 			[OK]\n");
			


if(!strcmp(argv[1], "-e"))
		{

			char request[1048];
			int motlen;
			int motadd;

			memset(request,0,1048);			
			motlen = strlen(argv[2]);
			motadd = motlen + 19;

			sprintf(request, "POST /md5/remote/index.php HTTP/1.1\r\n"
					 "Host: serveurhaksyn.free.fr\r\n"
					 "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1\r\n"
					 "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"
					 "Accept-Language: fr,fr-fr;q=0.8,en-us;q=0.5,en;q=0.3\r\n"
					 "Accept-Encoding: gzip,deflate\r\n"
					 "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r\n"
					 "Keep-Alive: 300\r\n"
					 "Connection: keep-alive\r\n"
					 "Referer: http://serveurhaksyn.free.fr/md5/remote/index.php\r\n"
					 "Cookie: __utma=172764660.1616335530061152000.1220863613.1220863613.1220863613.1; __utmz=172764660.1220863613.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); PHPSESSID=eae5958f9f84df00318294835b633d7c\r\n"
					 "Content-Type: application/x-www-form-urlencoded\r\n"
					 "Content-Length: %d"
					 "\r\n"
					 "\r\n"
					 "md5=%s&Submit=Crypter", motadd, argv[2]);
					

			if (send(mysocket2,request,strlen(request),0) != -1)
			{	
				char reponse[2048];
				memset(reponse,0,2048);
				printf("Send Request 			[OK]\n\n");
				recv(mysocket2,reponse,2048,0);
				printf("%s\n\n", reponse);
			}
			else
			{
				printf("Send request			[FAILED]\n");
				close(mysocket2);
				return 0;
			}
		
		}

if(!strcmp(argv[1], "-d"))
		{

			char request[1048];
			int motlen;
			int motadd;

			memset(request,0,1048);			
			motlen = strlen(argv[2]);
			motadd = motlen + 21;

			sprintf(request, "POST /md5/remote/decrypt.php HTTP/1.1\r\n"
					 "Host: serveurhaksyn.free.fr\r\n"
					 "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1\r\n"
					 "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"
					 "Accept-Language: fr,fr-fr;q=0.8,en-us;q=0.5,en;q=0.3\r\n"
					 "Accept-Encoding: gzip,deflate\r\n"
					 "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r\n"
					 "Keep-Alive: 300\r\n"
					 "Connection: keep-alive\r\n"
					 "Referer: http://serveurhaksyn.free.fr/md5/remote/decrypt.php\r\n"
					 "Cookie: __utma=172764660.1616335530061152000.1220863613.1220863613.1220863613.1; __utmz=172764660.1220863613.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); PHPSESSID=eae5958f9f84df00318294835b633d7c\r\n"
					 "Content-Type: application/x-www-form-urlencoded\r\n"
					 "Content-Length: %d"
					 "\r\n"
					 "\r\n"
					 "md5=%s&Submit=Decrypter", motadd, argv[2]);
					

			if (send(mysocket2,request,strlen(request),0) != -1)
			{	
				char reponse[2048];
				memset(reponse,0,2048);
				printf("Send Request 			[OK]\n\n");
				recv(mysocket2,reponse,2048,0);
				printf("%s\n\n", reponse);
			}
			else
			{
				printf("Send request			[FAILED]\n");
				close(mysocket2);
				return 0;
			}
		
		}		

		}
		else
	    	{
			printf("Connect 		[FAILED]\n\n");
			close(mysocket2);
	    	}
	


return 0;
}

