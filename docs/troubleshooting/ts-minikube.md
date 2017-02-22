# Troubleshooting - Minikube

This troubleshooting guide is intended to assist users who are developing charts within this repository when using minikube.
If you discover any issues with Minikube itself, submit an issue to the Minikube repository.

## Diagnosing the problem

In order to protect your general sanity, we've included a curated list of verification and troubleshooting steps that may help you avoid some potential issues while developing Openstack-Helm.

**MariaDB**<br>
To verify the state of MariaDB, use the following command:

```
$ kubectl exec mariadb-0 -it -n openstack -- mysql -u root -p password -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
$
```

**Helm Server/Repository**<br>
Sometimes you will run into Helm server or repository issues. For our purposes, it's mostly safe to whack these. If you are developing charts for other projects, use at your own risk (you most likely know how to resolve these issues already).

To check for a running instance of Helm Server:

```
$ ps -a | grep "helm serve"
29452 ttys004    0:00.23 helm serve .
35721 ttys004    0:00.00 grep --color=auto helm serve
```

Kill the "helm serve" running process:

```
$ kill 29452
```

To clear out previous Helm repositories, and reinstall a local repository:

```
$ helm repo list
NAME  	URL
stable	https://kubernetes-charts.storage.googleapis.com/
local 	http://localhost:8879/charts
$
$ helm repo remove local
```

This allows you to read your local repository, if you ever need to do these steps:

```
$ helm repo add local http://localhost:8879/charts
```
