krew: k8s的插件管理器
# 

install:
(
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')" &&
  "$KREW" install krew
)

set $PATHa:
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

kubectl krew update
kubectl krew search
kubectl krew install ingress-nginx


