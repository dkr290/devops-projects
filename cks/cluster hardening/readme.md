k create sa accessor


## depends on the following properties it mounts the token from the serviceaccount
```
serviceAccountName: accessor
automountServiceAccountToken: false
```

```
k apply -f accessor.yaml
```

## limit sa with RBAC

```
k auth can-i delete secrets --as system:serviceaccount:default:accessor  //no
k create clusterrolebinding accessor --clusterrole edit --serviceaccount default:accessor

k auth can-i delete secrets --as system:serviceaccount:default:accessor 




create token for the serviceaccount
k create -f token-for-svc.yaml
```


```
 k config view --raw
 ## extract the keys like echo "string" | base64 --decode to ca, cert,key
client-certificate-data  extract  > key 
client-key-data     extract > cert
certificate-authority-data extract > ca

example
 echo  LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkxxxxxxxxxxxxxxxxxxxxxxxxx | base64 --decode > ca



 then 

 kubectl cluster-info

 example:
  curl https://10.145.85.4:6443 --cacert ca.cer --cert crt.crt --key key
```


```
k edit svc kubernetes // change it to NodePort


```