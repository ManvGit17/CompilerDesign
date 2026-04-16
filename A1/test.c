#include<stdio.h>

int main() {
    int a = 5, b, c = 10, d;
    double e;
    int arr1[15];
    int arr2[10][10];
    int arr3[1][2][3][4];
    int arr4[4][4], arr5[5];
    int *ptr = &a;
    
    int x = sizeof(a,e);
    printf("Output %d",x);
    for (int i = 0, j = 0; i < 10 && j < 10; i++, j++) {
        a = a + i;
    }
    
    while (a > 0) {
        a--;
    }
    
    switch (b) {
        case 1:
            a = 10;
            break;
        case 2:
            a = 20;
            break;
        default:
            a = 0;
    }
    
    return 0;
}