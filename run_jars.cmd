@echo off

set name1=cd2db
set name2=cd2db_untyped
set name3=csv2pa_jackson
set name4=csv2pa_untyped

java -Xmx24g -XX:+AggressiveHeap -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=20 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70 -jar .\jars\%name1%.jar
java -Xmx24g -XX:+AggressiveHeap -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=20 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70 -jar .\jars\%name2%.jar
java -Xmx24g -XX:+AggressiveHeap -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=20 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70 -jar .\jars\%name3%.jar
java -Xmx24g -XX:+AggressiveHeap -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=20 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70 -jar .\jars\%name4%.jar
