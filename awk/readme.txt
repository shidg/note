# system
# e.g.
kubectl get pod -n kube-system |grep kube-proxy |awk '{system("kubectl delete pod "$1" -n kube-system")}'
kubectl get pod -n kube-system |grep kube-proxy |awk '{cmd="kubectl delete pod "$1" -n kube-system";system(cmd)}'

awk '{cmd="./test decrypt" $0; system(cmd)}' a.txt  > b.txt

# getline
# 获取输出并保存到变量中
# 这里之所以需要放到BEGIN中是因为该语句根本就没有扫描任何文件，也就是没有输入
# 而BEGIN的作用就是在开始扫描之前执行指定操作
awk 'BEGIN{system("date") | getline out;print out}'
