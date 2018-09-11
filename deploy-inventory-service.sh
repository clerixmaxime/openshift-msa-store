#!/bin/bash
oc set triggers dc/inventory-service --manual -n msa-store-dev

oc tag msa-store-dev/inventory-service:latest msa-store-dev/inventory-service:promoteToProd
oc rollout latest dc/inventory-service-blue -n msa-store-prod
oc rollout latest dc/inventory-service-green -n msa-store-prod
