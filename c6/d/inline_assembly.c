#include<stdio.h>
int in_a=1,in_b=2,out_sum;

void main(){
	asm("pusha; \
	     movl in_a, %eax;\
	     movl in_b, %ebx;\
	     addl %ebx, %eax;\
	     movl %eax, out_sum;\
	     popa;");
	printf("basic inline assembly:sum is %d\n", out_sum);

	asm("addl %%ebx,%%eax":"=a"(out_sum):"a"(in_a),"b"(in_b));
	printf("extended inline assembly: sum is %d\n", out_sum);
}
