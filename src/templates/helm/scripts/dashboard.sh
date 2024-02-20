#!/bin/bash

########################################################################################################
### Links
### ----------------------------------------------------------------------------------------------------
### https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
### https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
########################################################################################################

NAMESPACE='kubernetes-dashboard'
CLUSTER_ADMIN_USER='admin-user'
HOST='dashboard.localdev.me'

echo ""
echo "Namespace Dashboard: $NAMESPACE"
echo "Cluster Admin User: $CLUSTER_ADMIN_USER"
echo "Host: $HOST"

### Apply Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

### Add Service Account User
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $CLUSTER_ADMIN_USER
  namespace: $NAMESPACE
EOF

### Create a ClusterRoleBinding
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $CLUSTER_ADMIN_USER
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: $CLUSTER_ADMIN_USER
  namespace: $NAMESPACE
EOF

### Get Service Account Token
kubectl -n kubernetes-dashboard create token $CLUSTER_ADMIN_USER

### Create local proxy (**Will need ingress on deployed)
kubectl proxy

### Create Ingress for Dashboard
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dashboard-ingress
  namespace: $NAMESPACE
  annotations:
    # nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    ## Uncomment and configure these if you need basic auth
    # nginx.ingress.kubernetes.io/auth-type: basic
    # nginx.ingress.kubernetes.io/auth-secret: basic-auth
    # nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
spec:
  rules:
  - host: $HOST
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: k8s-dashboard
            port:
              number: 443
EOF