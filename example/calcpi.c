#include <stdio.h>

int main (int narg,char **sarg){
	long n=100000000,c1=0,c2=0,c3=0,c4=0;
	double pi=0,p1=0,p2=0,p3=0,p4=0;

	#pragma acc data copyin(n,c1,c2,c3,c4) copy(p1,p2,p3,p4)
    	{
		#pragma acc parallel loop
		for(c1=1;c1<n;c1+=4)
			p1+=4.0/c1;

		#pragma acc parallel loop
		for(c2=3;c2<n;c2+=4)
			p2-=4.0/c2;
    	}
	pi=p1+p2+p3+p4;

	printf("PI=%2.50f\n",pi);
	return 0;
}

