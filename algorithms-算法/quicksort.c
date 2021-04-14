int rand_range(int min, int max)
{
    return rand() % (max - min + 1) + min;
}

int partition(char *array, int start, int end)
{
    int rand_idx = rand_range(start, end);
    swap(array[rand_idx], array[end]);
    int left = start;
    for(int right = start; right < end; right++)
    {
        if(array[right] < array[end])
        {
            swap(array[left], array[right]);
            left++;
        }
    }
    swap(array[end], array[left]);
    return left;
}
