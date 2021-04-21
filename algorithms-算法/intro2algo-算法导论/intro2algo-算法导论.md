本文章是《算法导论 原书第3版 -- 机械工业出版社》算法的C语言实现。

注意：还未全部完成，更新中。。。

# 快速排序

第95页

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

