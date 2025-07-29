#!/bin/bash
# get-gcp-inventory.sh
# -----------------------------------------------------------------------------
# Counts key resource types across every GCP project visible to your gcloud account.
#
# Categories reported (to match your other cloud scripts):
#   • Virtual Machines           → Compute Engine instances
#   • Cloud Databases            → Cloud SQL + Cloud Spanner instances
#   • Serverless Functions       → Cloud Functions (v1 + v2)
#   • Container Hosts            → Google Kubernetes Engine (GKE) clusters
#   • Serverless Containers      → Cloud Run services
#
# Prerequisites:
#   • gcloud CLI installed and authenticated
#   • jq not required
#   • Sufficient IAM rights to list resources in each project
# -----------------------------------------------------------------------------

# Totals across all projects
total_vms=0
total_dbs=0
total_functions=0
total_gke_clusters=0
total_cloudrun=0

# Header
printf "\n%-30s %-18s %-18s %-22s %-18s %-22s\n" \
  "Project" "VirtualMachines" "CloudDatabases" "ServerlessFunctions" "ContainerHosts" "ServerlessContainers"

# Iterate over every project returned by gcloud
projects=$(gcloud projects list --format="value(projectId)")

for project in $projects; do
  # Silence config set output
  gcloud config set project "$project" >/dev/null

  # ---- Virtual Machines (Compute Engine) ----
  vm_count=$(gcloud compute instances list \
               --format="value(name)" --quiet 2>/dev/null | wc -l)

  # ---- Cloud Databases (SQL + Spanner) ----
  sql_count=$(gcloud sql instances list \
                --format="value(name)" --quiet 2>/dev/null | wc -l)
  spanner_count=$(gcloud spanner instances list \
                    --format="value(name)" --quiet 2>/dev/null | wc -l)
  db_count=$((sql_count + spanner_count))

  # ---- Serverless Functions (Cloud Functions v1 & v2) ----
  fn_v1_count=$(gcloud functions list \
                  --format="value(name)" --quiet 2>/dev/null | wc -l)
  fn_v2_count=$(gcloud functions v2 list \
                  --format="value(name)" --quiet 2>/dev/null | wc -l)
  function_count=$((fn_v1_count + fn_v2_count))

  # ---- Container Hosts (GKE clusters) ----
  gke_count=$(gcloud container clusters list \
                --format="value(name)" --quiet 2>/dev/null | wc -l)

  # ---- Serverless Containers (Cloud Run services) ----
  cloudrun_count=$(gcloud run services list \
                     --platform managed \
                     --format="value(metadata.name)" --quiet 2>/dev/null | wc -l)

  # Print per‑project row
  printf "%-30s %-18s %-18s %-22s %-18s %-22s\n" \
    "$project" "$vm_count" "$db_count" "$function_count" "$gke_count" "$cloudrun_count"

  # Update global totals
  total_vms=$((total_vms + vm_count))
  total_dbs=$((total_dbs + db_count))
  total_functions=$((total_functions + function_count))
  total_gke_clusters=$((total_gke_clusters + gke_count))
  total_cloudrun=$((total_cloudrun + cloudrun_count))
done

# Summary
echo "-----------------------"
echo "Summary Across All Projects:"
echo "-----------------------"
echo "Total Virtual Machines:       $total_vms"
echo "Total Cloud Databases:        $total_dbs"
echo "Total Serverless Functions:   $total_functions"
echo "Total Container Hosts:        $total_gke_clusters"
echo "Total Serverless Containers:  $total_cloudrun"

