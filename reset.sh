# blue
  oc create deploymentconfig inventory-service-blue --image=docker-registry.default.svc:5000/msa-store-dev/inventory-service:promoteToProd -n msa-store-prod
  oc set env dc/inventory-service-blue PORT=8080 JAEGER_SERVER_HOSTNAME=jaeger-agent.cockpit.svc.cluster.local -n msa-store-prod
  oc label dc inventory-service-blue color=blue -n msa-store-prod
  # green
  oc create deploymentconfig inventory-service-green --image=docker-registry.default.svc:5000/msa-store-dev/inventory-service:promoteToProd -n msa-store-prod
  oc set env dc/inventory-service-green PORT=8080 JAEGER_SERVER_HOSTNAME=jaeger-agent.cockpit.svc.cluster.local -n msa-store-prod
  oc label dc inventory-service-green color=green -n msa-store-prod

  oc rollout cancel dc/inventory-service-blue -n msa-store-prod
  oc rollout cancel dc/inventory-service-green -n msa-store-prod

  oc set triggers dc/inventory-service-blue --manual -n msa-store-prod
  oc set triggers dc/inventory-service-green --manual -n msa-store-prod

  oc patch dc inventory-service-blue -p '{"spec":{"template":{"metadata":{"labels":{"color":"blue"}}}}}' -n msa-store-prod
  oc patch dc inventory-service-green -p '{"spec":{"template":{"metadata":{"labels":{"color":"green"}}}}}' -n msa-store-prod

  oc get dc inventory-service-blue -o yaml -n msa-store-prod | sed 's/imagePullPolicy: IfNotPresent/imagePullPolicy: Always/g' | oc replace -f -
  oc get dc inventory-service-green -o yaml -n msa-store-prod | sed 's/imagePullPolicy: IfNotPresent/imagePullPolicy: Always/g' | oc replace -f -

  oc expose dc inventory-service-blue --port=8080 --selector="color=blue" -n msa-store-prod
  oc expose dc inventory-service-green --port=8080 --selector="color=green" -n msa-store-prod
  oc expose dc inventory-service-blue --name="inventory-service" --port=8080 --selector="color=blue" -n msa-store-prod
