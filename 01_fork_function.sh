#!/bin/bash

# змінні та функції експортуємо за-замовчуванням
set -a

# максимальна кількість дочірніх процесів
MAX_CHILDREN=4

# функція з нескінченним циклом
function run_infinite_loop {
    let chld_num=$1+1
    while : ; do
        echo "Children $chld_num works";
        sleep 1;
    done ;
}

# масив для збереження PID-ів дочірніх процесів
children_PID=()

# запускаємо необхідну кількість дочірніх процесів
for ((i=0; i<MAX_CHILDREN; i++)); do
    # виконуємо код функції в підпроцесі (фоновому процесі), додавши & в кінець рядку
    run_infinite_loop $i &
    # змінна $! містить PID останнього створеного підпроцесу
    background_process_id=$!
    echo "Process started in background: PID=${background_process_id}"
    # додаємо PID цього підпросесу в масив
    children_PID[$i]=$background_process_id
done

# даємо попрацювати
sleep 3

# почергово відправляємо сигнали завершення дочірнім процесам
for chldpid in ${children_PID[@]}; do
    echo "Sending SIGTERM to ${chldpid}..."
    # відправляємо сигнал процесу
    kill -n SIGTERM ${chldpid}

    if (( $? == 0 )) ; then
        echo "Process ${chldpid} was successfully terminated."
    else
        echo "Failed to terminate ${chldpid}."
    fi
done
