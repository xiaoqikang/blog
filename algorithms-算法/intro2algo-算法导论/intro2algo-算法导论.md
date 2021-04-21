本文章是《算法导论 原书第3版 -- 机械工业出版社》算法的C语言实现。

注意：还未全部完成，更新中。。。

# 快速排序

第95页

时间复杂度O(nlgn)，空间复杂度O(lgn)。

完整代码：[quik-sort.c](https://gitee.com/lioneie/blog/blob/master/algorithms-%E7%AE%97%E6%B3%95/intro2algo-%E7%AE%97%E6%B3%95%E5%AF%BC%E8%AE%BA/quick-sort.c)

核心函数：

```c
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
```

# 归并排序

第17页。

时间复杂度O(nlgn)，空间复杂度O(n)。

完整代码：[merge-sort.c](https://gitee.com/lioneie/blog/blob/master/algorithms-%E7%AE%97%E6%B3%95/intro2algo-%E7%AE%97%E6%B3%95%E5%AF%BC%E8%AE%BA/merge-sort.c)。

核心函数：

```c
static void merge(int *array, int start, int mid, int end)
{
    // 左边的数组包含下标mid
    int l_len = mid - start + 1;
    int r_len = end - mid;
    int *l_array = NULL;
    int *r_array = NULL;
    l_array = (int *)malloc(sizeof(int) * (l_len+1));
    r_array = (int *)malloc(sizeof(int) * (r_len+1));

    // 哨兵
    l_array[l_len] = INT_MAX;
    r_array[r_len] = INT_MAX;
    for(int i = 0; i < l_len; i++)
    {   
        l_array[i] = array[start+i];
    }   
    for(int i = 0; i < r_len; i++)
    {   
        r_array[i] = array[mid+i+1];
    }   

    int i = 0, j = 0;
    for(int k = start; k <= end; k++)
    {   
        if(l_array[i] <= r_array[j])
        {
            array[k] = l_array[i];
            i++;
        }
        else
        {
            array[k] = r_array[j];
            j++;
        }
    }   
    
    free(l_array);
    free(r_array);
}
```

# 堆排序

