 ```
 gpg --list-keys
 gpg --full-generate-key
 gpg --list-keys
 gpg --export-secret-keys >~/.gnupg/helmsigndemo-pv.gpg
 ls ~/.gnupg/
cp  ~/.gnupg/helmsigndemo-pv.gpg myhelmcharts/private-key/
cd myhelmcharts/
helm create myfirstchart 
gpg --list-keys
helm package  --sign --key 'helmsigndemo' --keyring private-key/helmsigndemo-pv.gpg myfirstchart/
```


#verify

```
gpg --export 'helmsigndemo' > public-key/helmsigndemo-pub

helm verify --keyring  public-key/helmsigndemo-pub myfirstchart-0.1.0.tgz
```

## install and upgrade
```
helm install myapp myfirstchart-0.1.0.tgz --verify --keyring public-key/helmsigndemo-pub
```

# negative test

```
touch public-key/dummy-key-pub

helm install myapp myfirstchart-0.1.0.tgz --verify --keyring public-key/dummy-key-pub --atomic
```