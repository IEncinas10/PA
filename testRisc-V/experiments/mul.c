#define ARR_SIZE 128

int main() {
    static unsigned ones[ARR_SIZE][ARR_SIZE] = {[0 ... ARR_SIZE - 1][0 ... ARR_SIZE - 1] = 1};
    static unsigned twos[ARR_SIZE][ARR_SIZE] = {[0 ... ARR_SIZE - 1][0 ... ARR_SIZE - 1] = 2};

    static unsigned result[ARR_SIZE][ARR_SIZE] = {[0 ... ARR_SIZE - 1][0 ... ARR_SIZE - 1] = -1};
    
    const unsigned size = ARR_SIZE;
    for(int i = 0; i < ARR_SIZE; i++)
	for(int j = 0; j < ARR_SIZE; j++) {

	    unsigned tmp = 0;
	    for(int k = 0; k < ARR_SIZE; k++) {
		tmp += ones[i][k] * twos[k][j];
	    }

	    result[i][j] = tmp;
	}

    while(1);
}
