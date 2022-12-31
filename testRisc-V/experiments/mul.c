#define ARR_SIZE 128

int main() {
    asm volatile ("addi t0, zero,8");
    asm volatile ("addi sp, zero,1536");
    asm volatile ("mul sp, sp,t0");

    static unsigned ones[ARR_SIZE][ARR_SIZE] = {[0 ... ARR_SIZE - 1][0 ... ARR_SIZE - 1] = 1};
    static unsigned twos[ARR_SIZE][ARR_SIZE] = {[0 ... ARR_SIZE - 1][0 ... ARR_SIZE - 1] = 2};

    static unsigned result[ARR_SIZE][ARR_SIZE] = {[0 ... ARR_SIZE - 1][0 ... ARR_SIZE - 1] = -1};
    int final = 0;

    const unsigned size = ARR_SIZE;
    for(int i = 0; i < ARR_SIZE; i++)
	for(int j = 0; j < ARR_SIZE; j++) {

	    unsigned tmp = 0;
	    for(int k = 0; k < ARR_SIZE; k++) {
		tmp += ones[i][k] * twos[k][j];
	    }

	    result[i][j] = tmp;
		final += tmp;
	}


    while(1);
}
