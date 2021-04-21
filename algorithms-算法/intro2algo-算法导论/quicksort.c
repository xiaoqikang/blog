#include <stdio.h>
#include <stdlib.h>

static void swap(int *a, int *b)
{
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

static int rand_range(int min, int max)
{
    return rand() % (max - min + 1) + min;
}

static int partition(int *array, int start, int end)
{
    int rand_idx = rand_range(start, end);
    swap(&array[rand_idx], &array[end]);
    int left = start;
    for(int right = start; right < end; right++)
    {
        if(array[right] < array[end])
        {
            swap(&array[left], &array[right]);
            left++;
        }
    }
    swap(&array[end], &array[left]);
    return left;
}

static void quiksort(int *array, int start, int end)
{
    int idx = 0;
    if(start < end)
    {
        idx = partition(array, start, end);
        quiksort(array, start, idx);
        quiksort(array, idx+1, end);
    }
}

int main()
{
    int array[] = {5, 8, 6, 7, 3, 4, 2, 1};
    int len = sizeof(array)/sizeof(array[0]);
    quiksort(array, 0, len - 1);
    printf("\n\r");
    for(int i = 0; i < len; i++)
    {
        printf(" %d", array[i]);
    }
    printf("\n\r");
}
