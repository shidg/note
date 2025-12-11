# 📘 **WebLogic 运维工程师——面试答题卡（20 题）**

------

## **1. 什么是 WebLogic Domain？包含哪些组件？**

Domain 是 WebLogic 的逻辑管理单元，包含：

- **AdminServer（管理节点）**：负责配置、部署、监控，不承担业务流量。
- **ManagedServer（业务节点）**：部署应用、对外提供服务。
- **Cluster（集群）**：多个 Managed Server 组成，用于负载均衡/高可用。
- **NodeManager**：用于远程启停服务。
- **配置文件（config.xml）** 是整个 Domain 的核心配置文件。

------

## **2. WebLogic 集群有哪些类型？**

- **水平集群（Horizontal）**：多个节点分布在多台主机上，生产常用。
- **垂直集群（Vertical）**：同一台机器上跑多个节点，适合机器少 CPU 多的情况。
- **特性**：支持负载均衡、Session 复制、Failover。

------

## **3. WebLogic 集群搭建的核心步骤是什么？**

1. 使用 **config.sh** 创建 Domain；
2. 启动 AdminServer；
3. 创建 ManagedServer；
4. 创建 Cluster；
5. 将 ManagedServer 加入 Cluster；
6. 配置 NodeManager；
7. 使用 Console 一键启动集群。

------

## **4. WebLogic 常用的配置文件有哪些？作用是什么？**

- **config.xml**：核心配置文件，保存集群、服务器、JDBC、JMS 等信息。
- **setDomainEnv.sh**：启动 JVM 参数、类路径。
- **nodemanager.properties**：NodeManager 端口、认证等参数。
- **servers/<server>/logs**：各节点日志。

------

## **5. WebLogic 的 Cluster Address 是什么？为什么重要？**

Cluster Address 是集群所有节点的地址列表，例如：

```
ms1:7003,ms2:7003
```

作用：

- 负载均衡
- Session 复制
- 故障转移
- 外部 LB（Nginx/Apache）对接时必须配置

面试高频必考。

------

## **6. WebLogic Session 复制有哪些模式？**

- **replication**（同步复制）
- **async-replication**（异步复制，性能最好）
- **database**（会话持久化到数据库）

生产最常见：**async-replication**。

------

## **7. WebLogic 的线程模型是什么？**

基于 ExecuteThread 模型，每个线程从 WorkManager 获取任务。

关键指标：

- **ExecuteThreadTotalCount**
- **HoggingThreadCount**
- **StuckThreadCount**
- **ThreadQueueLength**

重点：StuckThread 是判断系统是否阻塞的重要指标。

------

## **8. 什么是 Stuck Thread？如何排查？**

Stuck Thread = 长时间占用线程不释放，默认 600 秒未返回。
 排查方式：

- 日志中查看 stacktrace
- thread dump
- 是否 JDBC 长事务、死锁、外部接口超时
- 检查连接池是否耗尽

------

## **9. WebLogic JDBC 连接池需要关注哪些指标？**

- ActiveConnectionsCurrentCount
- WaitingForConnectionCurrentCount
- LeakedConnectionCount
- FailuresToReconnectCount
- ConnectionDelayTime

调优方向：连接池大小、连接超时、TestSQL 配置。

------

## **10. WebLogic 如何进行健康检查？**

通过 WebLogic Health State：

- **HEALTH_OK**
- **HEALTH_WARN**
- **HEALTH_CRITICAL**
- **HEALTH_FAILED**

监控方法：WLDF、JMX、Prometheus Exporter。

------

## **11. WebLogic 中 AdminServer 宕机会怎样？**

业务不受影响，只是：

- 无法进行部署更新
- 无法修改配置
- 无法使用 console 操作集群

Managed Server 会继续运行。

------

## **12. WebLogic 的安全 Realm 组件有哪些？**

- Authentication Provider（用户认证）
- Authorization Provider（授权）
- Adjudication Provider
- Role Mapping Provider
- Credential Mapping Provider

常用：DefaultAuthenticator / LDAPAuthenticator。

------

## **13. NodeManager 的作用是什么？**

- 远程启动/停止 ManagedServer
- 监控进程状态
- 配合 AdminServer 做自动恢复（Crash Recovery）

每台机器一般部署一个。

------

## **14. WebLogic 如何做高可用？**

- WebLogic 集群（MS1 / MS2）
- Session 复制（async）
- AdminServer 独立部署
- 结合 Apache/Nginx/硬件负载均衡器（F5、SLB）
- 数据源多数据源（Multi DataSource）

------

## **15. WebLogic 与 Nginx/Apache 如何进行负载均衡？**

- 通过 **mod_wl_ohs**（Apache）
- 或 Nginx 转发到 Cluster Address
- Session Sticky（session affinity）通常开启
- 心跳检测、健康检查需要额外配置

------

## **16. WebLogic 常见性能问题有哪些？**

- Stuck Thread 增多
- JDBC 连接池耗尽
- GC 频繁
- 后端接口长时间阻塞
- Session 复制压力导致 CPU 高

解决：调 JVM、调连接池、调整线程池、拆应用、限流降级。

------

## **17. WebLogic 如何调优 JVM？**

常用参数示例：

```
-Xms4g -Xmx4g
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+HeapDumpOnOutOfMemoryError
```

G1 在大内存下效果好。

------

## **18. WLDF（WebLogic Diagnostic Framework）能做什么？**

- 线程池监控
- 堆内存监控
- JDBC 指标
- StuckThread 告警
- 配置 Watch & Notification
- 日志过滤分析

生产中可推送至邮件/SMS/监控系统。

------

## **19. WebLogic 如何被 Prometheus/Grafana 监控？**

使用 **weblogic-monitoring-exporter**（官方提供）：

采集：

- JVM 指标
- 线程池
- JDBC 连接池
- Health 状态
- 集群状态

可配套 Grafana Dashboard。

------

## **20. WebLogic 常见故障排查思路？**

1. **查看 Admin/ManagedServer 日志**
2. 查看 StuckThread、HoggingThread
3. 检查 JDBC 连接池
4. 查看后端接口耗时
5. 检查 GC、堆内存
6. 抓 Thread Dump
7. 抓 GC log
8. 使用 WLDF 或 JMX 分析运行状态

面试答法：

> WebLogic 故障通常分为线程问题、数据库问题、外部接口问题和 JVM 内存问题四类，我会从日志、线程、JDBC、GC 四个方向排查。