# Kubernetes and Workload Identity

## Summary
This repo includes a PowerPoint presentation re use of AAD Workload identity for securing Kubernetes-based API client applications and some AKS-based demo code. (It also includes some experimental, incomplete code I am using to deploy same app in other k8s environments)

## Contents

PowerPoint resentation
ASP.NET MVC WebApp source (API client, calls a aGraph API)
Various yaml files
aks-deploy.ps1 with commands to create a cluster and deploy the above

## Deployment

The aks-deploy.ps1 script cannot currently do the complete deployment. AAD app registration still has to be done manually

