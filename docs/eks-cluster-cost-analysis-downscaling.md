# EKS Dev Cluster Cost Analysis & Downscaling Savings

**Analysis Date:** November 12, 2025  
**Cluster:** `aloware-dev-uswest2-eks-cluster-cr-01`  
**Data Source:** AWS Cost Explorer (actual billing data, Aug-Nov 2025)

---

## Executive Summary

By scaling the dev EKS cluster nodes to zero during off-hours, we can save **$204-310/month (41-62% of total cluster costs)** depending on the downtime window chosen.

**Recommended approach:** Scale nodes to 0 for 12 hours/day (8pm-8am) = **$204/month savings (41% reduction)**

---

## Current Cluster Configuration

- **Cluster:** `aloware-dev-uswest2-eks-cluster-cr-01` (EKS v1.34)
- **Node group:** `aloware-dev-uswest2-eks-nodegroup-cr-04`
- **Instance type:** m7g.2xlarge (8 vCPU, 32 GB RAM, Graviton3)
- **Current sizing:** 
  - Min: 4 nodes
  - Max: 8 nodes
  - Desired: 4 nodes
- **Capacity:** ON_DEMAND (with Savings Plan pricing applied)
- **Region:** us-west-2 (Oregon)

---

## Actual Billed Costs (AWS Cost Explorer)

| Month | m7g.2xlarge EC2 (node compute) | EKS Control Plane | Total EKS Cluster | Usage Hours (total) |
|-------|-------------------------------|-------------------|-------------------|---------------------|
| **Aug 2025** | $0.00 | $148.80 | $148.80 | 0 hours |
| **Sep 2025** | $0.00 | $144.00 | $144.00 | 0 hours |
| **Oct 2025** | **$339.75** | $148.80 | **$488.55** | 2,400 hours |
| **Nov 2025** (12 days) | **$115.72** | $52.80 | **$168.52** | 1,056 hours |

### Key Observations

1. **Cluster started running in October 2025** (no compute costs Aug-Sep)
2. **October actual cost:** $488.55 total
   - Compute: $339.75 (2,400 hours across 4 nodes)
   - Control plane: $148.80
3. **Current uptime pattern:** ~620 hours/node/month out of 744 possible = **83.3% uptime** (already scaled down ~17% of the time)
4. **Effective hourly rate:** $0.1416/hour per node (Savings Plan pricing vs $0.3264 on-demand = **56.6% discount already applied**)
5. **Control plane cost:** $0.10/hour × 744h × 2 clusters = $148.80/month (fixed, cannot be reduced by node scaling)

---

## Monthly Cost Baseline (Full Month Projection)

Based on current usage pattern (~620 hours/node/month):

| Cost Component | Monthly Cost |
|----------------|--------------|
| **Compute (4 nodes)** | $351.55 |
| **EKS Control Plane** | $148.80 |
| **Total** | **$500.35** |

---

## Downscaling Savings Scenarios

All scenarios assume scaling nodes to **0** during specified hours (control plane continues running).

### Scenario 1: Scale to 0 for 8 hours/day (nights)
**Example schedule:** 10pm-6am daily

- **Downtime:** 8 hours/day × 30 days = 240 hours/month
- **Current uptime:** 620 hours/node/month
- **New uptime:** 620 - 240 = 380 hours/node/month
- **New compute cost:** 4 nodes × 380h × $0.1416 = $215.23/month
- **Control plane:** $148.80/month (unchanged)
- **New total:** $364.03/month

| Metric | Value |
|--------|-------|
| **Monthly savings** | **$136.32** |
| **Compute savings** | 38.8% |
| **Total savings** | 27.3% |

---

### Scenario 2: Scale to 0 for 12 hours/day ⭐ **RECOMMENDED**
**Example schedule:** 8pm-8am daily

- **Downtime:** 12 hours/day × 30 days = 360 hours/month
- **Current uptime:** 620 hours/node/month
- **New uptime:** 620 - 360 = 260 hours/node/month
- **New compute cost:** 4 nodes × 260h × $0.1416 = $147.26/month
- **Control plane:** $148.80/month (unchanged)
- **New total:** $296.06/month

| Metric | Value |
|--------|-------|
| **Monthly savings** | **$204.29** |
| **Compute savings** | 58.1% |
| **Total savings** | 40.9% |

---

### Scenario 3: Scale to 0 weeknights + all weekend (aggressive)
**Example schedule:** 8pm-8am weeknights + all day Saturday-Sunday

- **Weeknight downtime:** 12 hours × 5 days × 4.3 weeks = 258 hours
- **Weekend downtime:** 48 hours × 2 days × 4.3 weeks = 412.8 hours
- **Total downtime:** 670.8 hours/month
- **Current uptime:** 620 hours/node/month
- **New uptime:** ~73 hours/node/month (only brief weekday business hours)
- **New compute cost:** 4 nodes × 73h × $0.1416 = $41.35/month
- **Control plane:** $148.80/month (unchanged)
- **New total:** $190.15/month

| Metric | Value |
|--------|-------|
| **Monthly savings** | **$310.20** |
| **Compute savings** | 88.2% |
| **Total savings** | 62.1% |

---

## Summary Table

| Scenario | Downtime (hours/month) | Current Cost | New Cost | Savings | % Compute Saved | % Total Saved |
|----------|----------------------|--------------|----------|---------|-----------------|---------------|
| **Current (baseline)** | ~124h (17% down) | $500.35 | - | - | - | - |
| **8h/day nights** | 240h | $500.35 | $364.03 | **$136.32** | 38.8% | 27.3% |
| **12h/day** ⭐ | 360h | $500.35 | $296.06 | **$204.29** | 58.1% | 40.9% |
| **Nights + weekends** | 671h | $500.35 | $190.15 | **$310.20** | 88.2% | 62.1% |

---

## Important Considerations

### Current Pricing Benefits
- **Savings Plan discount already applied:** ~56% off on-demand pricing ($0.1416/hr vs $0.3264/hr)
- Any additional Savings Plan commitment should be evaluated carefully given planned downscaling

### What Costs Remain When Scaled to 0
- **EKS control plane:** $148.80/month (cannot be stopped)
- **EBS volumes:** attached to nodes continue accruing storage costs (~$0.08-0.10/GB/month)
- **Data transfer, NAT gateway, Load Balancers:** if they remain provisioned

### Scaling Mechanics
- **Scaling down:** Update node group `minSize=0, maxSize=0, desiredSize=0`
- **Scaling up:** Update node group back to `minSize=4, maxSize=8, desiredSize=4`
- **Startup time:** ~2-5 minutes for nodes to become ready after scaling up
- **Pod recovery:** Deployments will reschedule pods automatically once nodes are available

---

## Implementation Options

### Option 1: Manual Scaling (immediate, no automation)
```bash
# Scale down
aws eks update-nodegroup-config \
  --cluster-name aloware-dev-uswest2-eks-cluster-cr-01 \
  --nodegroup-name aloware-dev-uswest2-eks-nodegroup-cr-04 \
  --scaling-config minSize=0,maxSize=0,desiredSize=0

# Scale up
aws eks update-nodegroup-config \
  --cluster-name aloware-dev-uswest2-eks-cluster-cr-01 \
  --nodegroup-name aloware-dev-uswest2-eks-nodegroup-cr-04 \
  --scaling-config minSize=4,maxSize=8,desiredSize=4
```

### Option 2: Scheduled Scaling with Lambda + EventBridge
- Create Lambda function that calls `update-nodegroup-config`
- EventBridge cron rules trigger scale-down (8pm) and scale-up (8am)
- Handles timezone and weekend logic
- Cost: ~$0.20/month (Lambda execution)

### Option 3: Karpenter (advanced)
- Modern cluster autoscaler with fine-grained control
- Can consolidate workloads and scale more efficiently
- Requires migration from node groups to Karpenter provisioners

### Option 4: Cluster Autoscaler with scheduled constraints
- Use cluster-autoscaler with min/max node annotations
- Less precise than Lambda but integrates with existing autoscaling

---

## Recommendation

**Implement Scenario 2 (12 hours/day downtime) using Lambda + EventBridge scheduled scaling**

### Why this approach?
1. **Best ROI:** $204/month savings (41% reduction) with minimal operational impact
2. **Safe downtime window:** 8pm-8am covers typical low-usage hours
3. **Simple automation:** Lambda + EventBridge is reliable and low-cost
4. **Flexible:** Easy to adjust schedule or disable if needed
5. **Fast recovery:** 2-5 minute startup when devs need the cluster outside scheduled hours

### Annual Savings Projection
- Monthly: $204.29
- **Annual: $2,451.48**

### Next Steps
1. Validate dev team's actual usage patterns (confirm 8pm-8am is safe downtime)
2. Create Lambda function for scheduled scaling
3. Set up EventBridge rules with appropriate timezone handling
4. Test scale-down/scale-up cycle during a low-risk period
5. Monitor for 1-2 weeks and adjust schedule if needed
6. Consider extending to nights + weekends (Scenario 3) after validation

---

## Additional Cost Optimization Opportunities (Future)

1. **Spot instances:** Use spot for non-critical workloads (60-90% savings on compute)
2. **Right-sizing:** Analyze actual CPU/memory usage; may be able to use smaller instance types
3. **Fargate for batch jobs:** Move scheduled/batch workloads to Fargate (pay per pod runtime)
4. **Reserved Instances/Savings Plans:** If uptime remains >50% after downscaling, evaluate additional commitment
5. **Consolidate control planes:** If running multiple small clusters, consider consolidating to reduce control plane costs

---

**Analysis prepared by:** Copilot  
**Data source:** AWS Cost Explorer API  
**Last updated:** November 12, 2025
