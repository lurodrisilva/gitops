   1 # Enabling and Disabling Addons
   2 
   3 This guide explains how to enable or disable platform addons.
   4 
   5 ## Overview
   6 
   7 Addons are controlled via `base_chart/values.yaml`. Each addon has an `enabled` flag that determines whether it's deployed.
   8 
   9 ## Enabling an Addon
  10 
  11 ### Step 1: Edit values.yaml
  12 
  13 ```bash
  14 vim base_chart/values.yaml
  15 ```
  16 
  17 Find the addon and change `enabled: false` to `enabled: true`:
  18 
  19 ```yaml
  20 metrics_server:
  21   addon_name: metrics-server
  22   enabled: true              # Change from false to true
  23   namespace: control-plane-system
  24 ```
  25 
  26 ### Step 2: Commit and Push
  27 
  28 ```bash
  29 git add base_chart/values.yaml
  30 git commit -m "Enable metrics-server addon"
  31 git push
  32 ```
  33 
  34 ### Step 3: Wait for Sync
  35 
  36 ArgoCD automatically syncs within ~3 minutes. Monitor progress:
  37 
  38 ```bash
  39 # Watch for new application
  40 watch kubectl get applications -n control-plane-system
  41 
  42 # Once it appears, check its status
  43 kubectl describe application metrics-server -n control-plane-system
  44 ```
  45 
  46 ### Step 4: Verify Deployment
  47 
  48 ```bash
  49 # Check if pods are running
  50 kubectl get pods -n control-plane-system -l app.kubernetes.io/instance=metrics-server
  51 
  52 # Verify the addon is functioning
  53 kubectl top nodes  # For metrics-server specifically
  54 ```
  55 
  56 ## Disabling an Addon
  57 
  58 ### Step 1: Edit values.yaml
  59 
  60 ```bash
  61 vim base_chart/values.yaml
  62 ```
  63 
  64 Change `enabled: true` to `enabled: false`:
  65 
  66 ```yaml
  67 metrics_server:
  68   addon_name: metrics-server
  69   enabled: false             # Change from true to false
  70   namespace: control-plane-system
  71 ```
  72 
  73 ### Step 2: Commit and Push
  74 
  75 ```bash
  76 git add base_chart/values.yaml
  77 git commit -m "Disable metrics-server addon"
  78 git push
  79 ```
  80 
  81 ### Step 3: Verify Removal
  82 
  83 ArgoCD will automatically prune (delete) the Application:
  84 
  85 ```bash
  86 # Verify application is removed
  87 kubectl get applications -n control-plane-system | grep metrics-server
  88 
  89 # Verify resources are cleaned up
  90 kubectl get all -n control-plane-system -l app.kubernetes.io/instance=metrics-server
  91 ```
  92 
  93 ## Manual Sync
  94 
  95 To immediately sync changes instead of waiting:
  96 
  97 ```bash
  98 # Sync the base chart application
  99 kubectl patch application gitops -n control-plane-system \
 100   --type merge -p '{"operation":{"sync":{}}}'
 101 ```
 102 
 103 ## Currently Enabled Addons
 104 
 105 Check `base_chart/values.yaml` for current status. As of now:
 106 
 107 - ✅ cert-manager
 108 - ✅ reloader  
 109 - ✅ cloudnative-pg
 110 
 111 All others are disabled by default.
 112 
 113 ## Best Practices
 114 
 115 1. **Enable one addon at a time** to easily troubleshoot issues
 116 2. **Monitor resource usage** before enabling resource-intensive addons
 117 3. **Review addon documentation** in `addon_charts/<name>/` before enabling
 118 4. **Test in dev first** before enabling in production
 119 5. **Keep values.yaml clean** - remove commented sections
 120 
 121 ## Troubleshooting
 122 
 123 ### Addon Not Appearing
 124 
 125 ```bash
 126 # Check if gitops app synced successfully
 127 kubectl get application gitops -n control-plane-system
 128 
 129 # Force sync
 130 kubectl patch application gitops -n control-plane-system \
 131   --type merge -p '{"operation":{"sync":{}}}'
 132 ```
 133 
 134 ### Addon Failed to Deploy
 135 
 136 ```bash
 137 # Check application status
 138 kubectl describe application <addon-name> -n control-plane-system
 139 
 140 # View ArgoCD logs
 141 kubectl logs -n devops-system -l app.kubernetes.io/name=argocd-application-controller
 142 ```
 143 
 144 ### Addon Not Pruning
 145 
 146 ```bash
 147 # Manually delete the application
 148 kubectl delete application <addon-name> -n control-plane-system
 149 
 150 # Clean up remaining resources
 151 kubectl delete all -n <namespace> -l app.kubernetes.io/instance=<addon-name>
 152 ```
 153 
 154 ## Related Documentation
 155 
 156 - [Addon Reference](../reference/addon-list.md) - Complete addon list
 157 - [Adding Addons](adding-addons.md) - Add custom addons
 158 - [GitOps Workflow](../architecture/gitops-workflow.md) - Understanding the flow
