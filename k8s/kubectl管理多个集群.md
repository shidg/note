# 生成证书并使用k8s的CA证书签名
```shell
openssl genrsa -out username.key 2048
openssl req -new -key username.key -out username.csr -subj "/CN=shidg/O=MGM"
openssl x509 -req -in username.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out username.crt -days 3650
```
# 为k8s绑定一个外部用户（授予这个用户相应的权限）
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: shidg
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ""
subjects:
  - kind: User
    name: username
    apiGroup: ""
```
# 添加k8s集群
```shell
kubectl config set-cluster g3 --certificate-authority=/root/.kube/g1/ca.crt --embed-certs=true --server=https://172.27.3.160:6443
```
# 添加用户
```shell
kubectl config set-credentials shidg --client-certificate=/root/.kube/g3/shidg.crt --client-key=/root/.kube/g3/shidg.key --embed-certs=true
```
# 添加context
```shell
kubectl config set-context g3 --cluster=g3 --user=username
```
# 查看并选择context
```shell
kubectl config get-contexts
kubectl config use-context xx
```