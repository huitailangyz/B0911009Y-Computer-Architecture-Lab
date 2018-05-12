#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <setjmp.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include<sys/socket.h>
#include <errno.h>
#include <signal.h>

int main(int argc,char **argv)
{
	int fd,sockfd,ret;
	int err;
	struct sockaddr_in addr;
	socklen_t addrlen=sizeof(addr);

	fd=socket(AF_INET,SOCK_STREAM,0);
	ret = 1;
	setsockopt(fd,SOL_SOCKET,SO_REUSEADDR,&ret,4);
	addr.sin_family=AF_INET;
	addr.sin_addr.s_addr=inet_addr("0.0.0.0");
	addr.sin_port=htons(argc<2?8888:strtoul(argv[1],0,0));
	ret=bind(fd,&addr,16);
	if(ret<0)
	{
		perror("bind error");
		goto out;
	}

	ret = listen(fd,1);
	if(ret<0)
	{
		perror("listen error");
		goto out;
	}

	while(1)
	{
		struct timeval tv, tv0;
		unsigned int t, t0, t1;
		float x,y;
		int first;
		ret = sockfd = accept(fd,&addr,&addrlen);
		if(sockfd<0)
		{
			printf("accept error:%s\n",strerror(errno));
			goto out;
		}

		first=1;


		while(1)
		{

		err=recv(sockfd,&t,4,0);
		if(err<=0) break;
		gettimeofday(&tv, 0);
		if(first)
		{
		 tv0 = tv;
		 t0 = t;
		 first = 0;
		}
		t1 = t;

		t = tv.tv_sec;
		err = send(sockfd,&t,4,0);
		if(err<=0) break;
		}

		x=(tv.tv_sec*1000000 + tv.tv_usec)-(tv0.tv_sec*1000000 + tv0.tv_usec);
		y=(t1-t0)*2;
	 	printf("%x %x clk %fM\n", t1,t0,y/x);	
		

	 }


out:

	close(fd);

	return 0;

}
