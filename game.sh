###
 # @Author: F1
 # @Date: 2021-12-08 19:21:30
 # @LastEditTime: 2021-12-11 17:01:49
 # @LastEditors: F1
 # @Description: 
 #  * 
 #  *				口算练习
 #  *
 # @FilePath: /shell/game.sh
 # 
### 
#!/bin/zsh


COUNT=50

CACL=2

CORRECT=0
INCORRECT=0

main() {
    clear
    CHOOSE="/tmp/$$_type"
    dialog --title "每 日 口 算 打 卡" --menu "\n准备好了吗？选择挑战项开始吧！！\n" 15 55 10 \
    0 "挑战 20 道加、减 口算（20以内）" \
    1 "挑战 50 道加、减 口算（20以内）" \
    2 "挑战 100 道加、减 口算（20以内）" \
    3 "挑战 20 道乘法口算" \
    4 "挑战 100 道混合口算（加、减、乘）" \
    5 "Exit" 2>$CHOOSE
    TYPE=`cat $CHOOSE`

    if [ $TYPE -eq 0 ]; then
        COUNT=20
        CACL=2
    fi
    if [ $TYPE -eq 1 ]; then
        COUNT=50
        CACL=2
    fi
    if [ $TYPE -eq 2 ]; then
        COUNT=100
        CACL=2
    fi
    if [ $TYPE -eq 4 ]; then
        COUNT=50
        CACL=3
    fi
    if [ $TYPE -eq 5 ]; then
        exit
    fi

    FAILEDS=()
    STARTTIME=`date +%s`
    INDEX=1
    while true
    do 
        NUM1=$(expr $RANDOM % 20)
        NUM2=$(expr $RANDOM % 20)

        FLAG=$(expr $RANDOM % 1000)
        FLAG=$(expr $FLAG % 2)

        # 只有乘法 
        if [ $TYPE -eq 3 ]; then
            COUNT=20
            FLAG=2
        fi
        RESULT=0
        RET=0
        while true
        do
            STR=""
            INPUTRESULT="/tmp/$$_$INDEX.txt"
            if [ $FLAG -eq 0 ]; then
                dialog --title "第 $INDEX 题，共 $COUNT 道" --inputbox "$NUM1 + $NUM2 =" 10 40 2>$INPUTRESULT
                RESULT=$(expr $NUM1 + $NUM2)
                STR="$NUM1+$NUM2=$RESULT"
            fi
            if [ $FLAG -eq 1 ]; then
                if [ $NUM1 -gt $NUM2 ]; then
                    dialog --title "第 $INDEX 题，共 $COUNT 道" --inputbox "$NUM1 - $NUM2 =" 10 40 2>$INPUTRESULT
                    RESULT=$(expr $NUM1 - $NUM2)
                    STR="$NUM1-$NUM2=$RESULT"
                else
                    dialog --title "第 $INDEX 题，共 $COUNT 道" --inputbox "$NUM2 - $NUM1 =" 10 40 2>$INPUTRESULT
                    RESULT=$(expr $NUM2 - $NUM1)
                    STR="$NUM2-$NUM1=$RESULT"
                fi
            fi
            if [ $FLAG -eq 2 ]; then
                NUM1=$(expr $RANDOM % 9)
                NUM2=$(expr $RANDOM % 9)
                let NUM1++
                let NUM2++
                dialog --title "第 $INDEX 题，共 $COUNT 道" --inputbox "$NUM1 * $NUM2 =" 10 40 2>$INPUTRESULT
                RESULT=$(expr $NUM1 \* $NUM2)
                STR="$NUM1*$NUM2=$RESULT"
            fi
            RET=`cat $INPUTRESULT`
            
            if [ "$RET" -gt 0 ] 2>/dev/null ; then 
                if [ $RESULT -eq $RET ]; then
                    let CORRECT++
                else
                    let INCORRECT++
                    FAILEDS[${#FAILEDS[*]}]=$STR"，你的答案：$RET"
                fi

                break
            fi
        done
        if [ $INCORRECT -ge 5 ]; then
            dialog --msgbox "错太多，你挑战失败！" 15 80
            exit
        fi
        if [ $INDEX -eq $COUNT ]; then
            break
        fi
        let INDEX++
    done
}


log_info() {
    echo -e "   \033[1;96m $1 \033[0m"
}

log_warn() {
    echo -e "   \033[1;93m $1 \033[0m"
}

log_err() {
    echo -e "   \033[1;31m $1 \033[0m"
}

main

ENDTIME=`date +%s`
TIME=$(expr $ENDTIME - $STARTTIME)

REPORT="/tmp/$$.report"
echo "本次挑战完毕">$REPORT
echo "">$REPORT
echo "用时："$TIME" 秒，总共：$COUNT 道">>$REPORT
echo "正确：$CORRECT 道">>$REPORT
echo "错误：$INCORRECT 道">>$REPORT
SCORE=$(expr $CORRECT \* 100)
SCORE=$(expr $SCORE / $COUNT)

echo "你的得分：$SCORE 分">>$REPORT
echo "">>$REPORT
echo "错题：">>$REPORT
for failed in ${FAILEDS[@]};do
    echo $failed>>$REPORT
done
#cat $REPORT
dialog --msgbox "$(cat $REPORT)" 30 80