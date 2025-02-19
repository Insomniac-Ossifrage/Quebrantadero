Reference: [Git Documentation](https://git-scm.com/docs/git-config)

---
```shell
git config --global http.proxy 'http://username:password@domainm:port'
git config --global https.proxy 'http://username:password@domainm:port'
```
---

Error: `'https://...': Unknown SSL protocol error in connection to ...:443` \
Possible self-signed certificate or proxy interceptor (MIDM proxy)
```shell
git config --global http.sslVerify false
git config --global https.sslVerify false
```
---

Error: `'https://...': Received HTTP code 407 from proxy after CONNECT` \
Possible invalid or erroneous proxy authentication method. 
```shell
git config --global http.proxyAuthMethod 'basic'
```
