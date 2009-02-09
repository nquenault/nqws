#include <stdio.h>

int main(int argc, char **argv)
{
#ifdef WIN32
	printf("Hello Win32 world :)\n");
#elif defined (linux)
	printf("Hello Linux world :)\n");
#else
	printf("Hello Others worlds :)\n");
#endif
	return 0;
}

