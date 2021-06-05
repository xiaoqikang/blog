# 打怪

从左到右打怪，初始状态每只怪物1点血。怪物两种类型：1型和0型怪物。1型怪物被打时，右边的所有0型怪物都加1点血。一次攻击会使怪物少1点血。

请问杀死所有怪物要多少次攻击？

输入描述：

> 输入第一行包含一个正整数n，怪物的个数。（1 <= n <= 100000)
>
> 输入第二行包含n个数，怪物的种类，0或1.

输出描述：

> 一个整数，攻击次数。

示例：

> 输入：
>
> ​	4
>
> ​	0 1 0 1
>
> 输出：
>
> ​	5

```c
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	int res = 0;
	int cnt = 0;
	int type_one_cnt = 0;
	int *array = NULL;
	int i;

	scanf("%d", &cnt);
	array = malloc(sizeof(*array) * cnt);
	for (i = 0; i < cnt; i++) {
		scanf("%d", &array[i]);
		if (1 == array[i]) {
			type_one_cnt++;
			res++;
		} else {
			res += (1+type_one_cnt);
		}
	}
	printf("%d", res);
	printf("\n\r");
	
	return 0;
}
```

# 递归洗牌

如果只有两张牌，交换位置。

如果有2^k张牌，分2堆，每堆2^(k-1)张，递归对两堆进行洗牌，然后将后一堆放在前一堆前面，则一轮洗牌完成。

现在桌子有2^n张牌，进行t轮洗牌后，这些牌的顺序？

输入描述：

> 第一行两个整数n和t。1 <= n <= 12，1 <= t <= 10^9
>
> 第二行包含2^n个整数a[i]，表示初始时牌的数字。1 <= a[i] <= 10^9

输出描述：

> t轮洗牌后，牌的顺序。

示例：

> 输入：
>
> ​	2 1
>
> ​	2 4 1 5
>
> 输出：
>
> ​	5 1 4 2

```c
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

static void swap(int *a, int *b)
{
	int tmp = *a;
	*a = *b;
	*b = tmp;
}

static void merge(int *array, int start, int mid, int end)
{
	for (int i = start; i <= mid; i++) {
		swap(&array[i], &array[i+mid+1]);
	}
}

static void swap_arr(int *array, int start, int mid, int end)
{
	if (1 == (end - start)) {
		swap(&array[start], &array[end]);
		return;
	}
	swap_arr(array, start, (mid-start)/2, mid);
	swap_arr(array, mid+1, (end-mid-1)/2, end);
	merge(array, start, mid, end);
}

static int core(int *array, int start, int mid, int end, int t)
{
	for (int i = 0; i < t; i++) {
		swap_arr(array, start, mid, end);
	}
}

int main()
{
	int order = 0;
	int t = 0;
	int cnt = 0;
	int *array = NULL;
	scanf("%d %d", &order, &t);
	cnt = pow(2, order);
	array = malloc(sizeof(*array)*cnt);
	for (int i = 0; i < cnt; i++) {
		scanf("%d", &array[i]);
	}
	//for (int i = 0; i < cnt; i++) {
	//	printf("%d ", array[i]);
	//}
	//printf("\n\r");
	core(array, 0, (cnt-1)/2, cnt-1, t);
	for (int i = 0; i < cnt; i++) {
		printf("%d ", array[i]);
	}
	printf("\n\r");
	
	return 0;
}
```

编译：

```shell
gcc main.c -lm
```

