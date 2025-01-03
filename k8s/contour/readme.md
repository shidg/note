### 2.3 Contour部署

官网：https://projectcontour.io/。

**版本兼容性矩阵(Compatibility Matrix)**查询：https://projectcontour.io/resources/compatibility-matrix/。


# helm install
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/contour --namespace contour --create-namespace

# yaml install
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

