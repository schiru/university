#! /bin/bash

rm server_out.txt client_out.txt;

for X in {b,d,g,o,r,s,v,w}{b,d,g,o,r,s,v,w}{b,d,g,o,r,s,v,w}{b,d,g,o,r,s,v,w}{b,d,g,o,r,s,v,w}
do
    echo $(./server 12345 $X | grep -o -E '[0-9]+') >> server_out.txt &
    sleep 0.01 && ./client localhost 12345 >> client_out.txt &
    wait %1 %2;
done

sum=0;
while read num;
    do sum=$(($sum + $num));
done < server_out.txt;

echo $sum;
