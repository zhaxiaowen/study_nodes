# k8s部署服务

#### 安装kubectl-aliases

```
https://github.com/ahmetb/kubectl-aliases#installation
```



#### helm部署gitlab

```
helm repo add gitlab-jh https://charts.gitlab.cn
helm repo update
helm  install -n gitlab gitlab gitlab-jh/gitlab \
  --timeout 600s \
  --set global.hosts.domain=zhaoxw.work \
  --set certmanager-issuer.email=zxw270194330@163.com 
  
# 获取初始密码  
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo 
```



#### 安装jellyfin

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jellyfin
  namespace: jellyfin
spec:
  selector:
    matchLabels:
      app: jellyfin
  template:
    metadata:
      labels:
        app: jellyfin
    spec:
      nodeSelector:
        node: node1
      containers:
      - env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: spec.nodeName
        - name: POD_NAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
        image: jellyfin/jellyfin
        imagePullPolicy: IfNotPresent
        name: jellyfin
        ports:
        - containerPort: 8096
          protocol: TCP
        resources:
          limits:
            cpu: '2'
            memory: 2Gi
          requests:
            cpu: '2'
            memory: 2Gi
        volumeMounts:
        - mountPath: /media
          name: media
        - mountPath: /config
          name: jellyfin-config
        - mountPath: /cache
          name: jellyfin-cache
      restartPolicy: Always
      volumes:
      - name: jellyfin-config
        hostPath:
          path: /data/jellyfin/config
          type: Directory
      - name: jellyfin-cache
        hostPath:
          path: /data/jellyfin/cache
          type: Directory
      - name: media
        hostPath:
          path: /data/movie
          type: Directory
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: jellyfin
  name: jellyfin
  namespace: jellyfin
spec:
  ports:
  - name: web
    port: 8096
    protocol: TCP
    targetPort: 8096
  selector:
    app: jellyfin
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jellyfin-ingress
  namespace: jellyfin
  annotations:
    kubernetes.io/ingress.class: "nginx"
    prometheus.io/http_probe: "true"
spec:
  rules:
  - host: jellyfin.zhaoxw.work
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: jellyfin
            port:
              number: 8096

```

#### tinymediamanager.yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tinymediamanager-server
  namespace: jellyfin
  labels:
    app: tinymediamanager-server
spec:
  selector:
    matchLabels:
      app: tinymediamanager-server
  template:
    metadata:
      labels:
        app: tinymediamanager-server
    spec:
      nodeSelector:
        node: node1
      containers:
      - name: tinymediamanager-server
        image: tinymediamanager:v2
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 5800
          name: http
        - containerPort: 5900
          name: tcp
        env:
        - name: GROUP_ID
          value: '0'
        - name: USER_ID
          value: '0'
        resources:
          limits:
            cpu: "200m"
            memory: 1Gi
          requests:
            cpu: "200m"
            memory: 1Gi
        volumeMounts:
        - name: tinymediamanager-data
          mountPath: /media
        - name: tinymediamanager-config
          mountPath: /config
        - name: localtime
          mountPath: /etc/localtime
          readOnly: true
      volumes:
      - name: localtime
        hostPath:
          path: /etc/localtime
      - name: tinymediamanager-data
        hostPath:
          path: /data/movie
          type: Directory
      - name: tinymediamanager-config
        hostPath:
          path: /data/tinymediamanager/config
          type: Directory

---
apiVersion: v1
kind: Service
metadata:
  name: tinymediamanager-server
  namespace: jellyfin
spec:
  ports:
  - name: http
    protocol: TCP
    port: 5800
    targetPort: http
  selector:
    app: tinymediamanager-server
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tinymediamanager-ingress
  namespace: jellyfin
  annotations:
    kubernetes.io/ingress.class: "nginx"
    prometheus.io/http_probe: "true"
spec:
  rules:
  - host: tinymediamanager.zhaoxw.work
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tinymediamanager-server
            port:
              number: 5800

```

#### tinymediamanager_Dockerfile

```
#为了解决不识别中文的问题
wget https://mirrors.aliyun.com/alpine/edge/testing/x86_64/font-wqy-zenhei-0.9.45-r2.apk 
apk add --allow-untrusted font-wqy-zenhei-0.9.45-r2.apk 
---

# Version: 0.0.1
FROM romancin/tinymediamanager
COPY font-wqy-zenhei-0.9.45-r2.apk /tmp/font-wqy-zenhei-0.9.45-r2.apk
RUN ["apk","add","--allow-untrusted","/tmp/font-wqy-zenhei-0.9.45-r2.apk"]
```

#### storageclass部署

* nfs-client-class.yaml

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: course-nfs-storage
provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
```

* nfs-client-sa.yaml

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: course-nfs-storage
provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
[root@node1 nfs_file]# cat nfs-client-sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nfs-client-provisioner
  namespace: default
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["create", "delete", "get", "list", "watch", "patch", "update"]

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: default
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
```

* nfs-client.yaml

```
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nfs-client-provisioner
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 192.168.50.201
            - name: NFS_PATH
              value: /data/k8s
      volumes:
        - name: nfs-client-root
          nfs:
            server: 192.168.50.201
            path: /data/k8s
```



