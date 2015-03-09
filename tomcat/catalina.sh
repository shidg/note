#在catalina.sh中添加以下参数
JAVA_OPTS="-Xms3000m -Xmx3000m -Xss1024K -XX:PermSize=64m -XX:MaxPermSize=128m"

参数详解
-Xms  JVM初始化堆内存大小
-Xmx  JVM堆的最大内存
-Xss   线程栈大小 
-XX:PermSize JVM非堆区初始内存分配大小
-XX:MaxPermSize JVM非堆区最大内存



建议和注意事项:

-Xms和-Xmx选项设置为相同堆内存分配，以避免在每次GC 后调整堆的大小，堆内存建议占内存的60%~80%;非堆内存是不可回收内存，大小视项目而定;线程栈大小推荐256k.
