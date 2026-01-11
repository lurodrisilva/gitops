# Documentation Index

Welcome to the AKS Baseline GitOps documentation. This repository manages Kubernetes platform addons using ArgoCD and the App-of-Apps pattern.

## 📖 Documentation Structure

```
docs/
├── setup/          # Getting started guides
├── guides/         # How-to guides  
├── architecture/   # Architecture documentation
└── reference/      # Reference documentation
```

## 🚀 Getting Started

1. [**Quickstart Guide**](setup/quickstart.md) - Get started with GitOps deployments
2. [**Enabling Addons**](guides/enabling-addons.md) - Enable/disable platform addons

## 📚 Documentation by Category

### Setup & Installation

| Document | Description |
|----------|-------------|
| [Quickstart Guide](setup/quickstart.md) | Complete guide to deploy and configure addons |

### How-To Guides

| Document | Description |
|----------|-------------|
| [Enabling Addons](guides/enabling-addons.md) | How to enable and disable addons |
| [Adding New Addons](guides/adding-addons.md) | How to add custom addons to the platform |

### Architecture & Design

| Document | Description |
|----------|-------------|
| [GitOps Workflow](architecture/gitops-workflow.md) | Understanding the GitOps deployment workflow |

### Reference Documentation

| Document | Description |
|----------|-------------|
| [Addon List](reference/addon-list.md) | Complete reference of all available addons |
| [Values Schema](reference/values-schema.md) | Complete values.yaml configuration reference |

## 🎯 Common Tasks

### I want to...

- **Enable a new addon** → [Enabling Addons](guides/enabling-addons.md)
- **Add a custom addon** → [Adding New Addons](guides/adding-addons.md)
- **Understand GitOps flow** → [GitOps Workflow](architecture/gitops-workflow.md)
- **See all available addons** → [Addon List](reference/addon-list.md)
- **Configure addons** → [Values Schema](reference/values-schema.md)

## 🔍 Quick Links

### Essential Commands

```bash
# Check addon status
kubectl get applications -n control-plane-system

# Manual sync
kubectl patch application <addon-name> -n control-plane-system \
  --type merge -p '{"operation":{"sync":{}}}'

# View logs
kubectl logs -n control-plane-system -l app.kubernetes.io/name=argocd-application-controller
```

### Key Files

- `base_chart/values.yaml` - Addon enable/disable configuration
- `base_chart/Chart.yaml` - Main Helm chart metadata
- `base_chart/templates/` - ArgoCD Application templates
- `addon_charts/` - Individual addon Helm charts

## 📂 Related Resources

- [Main README](../README.md) - Project overview
- [Infrastructure Repo](../../01-aks-tf/) - AKS and ArgoCD deployment

---

**Navigation**: [Back to Main README](../README.md)
