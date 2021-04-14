#include "stdio.h"
#include "string.h"
int main(int argc, char *argv[])
{
    int ret = 0;
    char front_str[1024];
    if(2 != argc)
    {
        goto fail;
    }
    //char tmp[] = "static void funcname(int arga, char *argb, struct stru *ptr)adfa";
    //char tmp[] = "static void funcname(void)adfa";
    //char *str = tmp;
    char *str = argv[1];

    //左括号
    char *l_bracket_pos = strchr(str, '(');
    if(NULL == l_bracket_pos)
    {
        goto fail;
    }
    //printf("\n\rleft bracket:%s\n\r", l_bracket_pos);

    //前面部分（左括号前）
    memset(front_str, 0, sizeof(front_str));
    strncpy(front_str, str, strlen(str) - strlen(l_bracket_pos));
    //printf("\n\rfront str:%s\n\r", front_str);

    //函数名前的空格
    char *func_front_space_pos = strrchr(front_str, ' ');
    if(NULL == func_front_space_pos)
    {
        goto fail;
    }

    //打印 @fn 和 @brief
    printf("\n\r/** @fn : %s", func_front_space_pos + 1);
    printf("\n\r  * @brief : ");

    //右括号
    char *r_bracket_pos = strchr(str, ')');
    if(NULL == r_bracket_pos)
    {
        goto fail;
    }
    //printf("\n\rright bracket:%s\n\r", r_bracket_pos);

    //参数
    char *none_arg_pos = strstr(l_bracket_pos, "void");
    if(NULL != none_arg_pos)
    {
        printf("\n\r  * @param : None");
    }
    else
{
        //参数前的空格
        char *arg_front_space_pos;
        //逗号
        char *comma_pos = strchr(l_bracket_pos, ',');
        while(NULL != comma_pos)
        {
            //前面部分（左括号到当前逗号）
            memset(front_str, 0, sizeof(front_str));
            strncpy(front_str, l_bracket_pos, strlen(l_bracket_pos) - strlen(comma_pos));
            //printf("\n\rfront str:%s\n\r", front_str);
            //参数前的空格
            arg_front_space_pos = strrchr(front_str, ' ');
            printf("\n\r  * @param %s : ", arg_front_space_pos + 1);
            //下一个逗号
            comma_pos = strchr(comma_pos + 1, ',');
        }
        //最后一个参数
        //前面部分（左括号到右括号）
        memset(front_str, 0, sizeof(front_str));
        strncpy(front_str, l_bracket_pos, strlen(l_bracket_pos) - strlen(r_bracket_pos));
        //printf("\n\rfront str:%s\n\r", front_str);
        //参数前的空格
        arg_front_space_pos = strrchr(front_str, ' ');
        printf("\n\r  * @param %s : ", arg_front_space_pos + 1);
    }

    //前面部分（左括号前）
    memset(front_str, 0, sizeof(front_str));
    strncpy(front_str, str, strlen(str) - strlen(l_bracket_pos));
    //printf("\n\rfront str:%s\n\r", front_str);
    //返回值
    char *return_pos = strstr(front_str, "void");
    printf("\n\r  * @return : ");
    if(NULL != return_pos)
    {
        printf("None");
    }
    printf("\n\r*/\n\r");

    ret = 0;
    goto ret;
fail:
    ret = 1;
    printf("\n\r################wrong arg, try again\n\r");
ret:
    return ret;
}
