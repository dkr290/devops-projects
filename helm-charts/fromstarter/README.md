```
rm -rf /home/user/.local/share/helm/starters/mystarterchart
mkdir  /home/user/.local/share/helm/starters
cp -r mystarterchart/ /home/user/.local/share/helm/starters/
helm create fromstarter --starter=mystarterchart
```