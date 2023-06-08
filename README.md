
**Online Boutique** is a cloud-first microservices demo application built my Google.
Online Boutique consists of an 11-tier microservices application. The application is a
web-based e-commerce app where users can browse items, add them to the cart, and purchase them.

I use this demo application to demonstrate the use of these tools and technologies : 
- **[Terraform]:**
  I used Terraform to provision a 3 node, 6 core, 24 GB RAM GKE ( Google Kubernetes Engine) Cluster that runs under $25 month. The cluster is created in a Private VPC and adheres to the best practices.
- **[Kubernetes]:**
  Kubernetes is the main component of this demo project. It ensure the microservices application is highly available, orchestrates self healing and provides a canvas to add on an arsenal of Kubernetes native tools and technologies.
- **[ArgoCD]:**
  After the Kubernetes cluster is provisioned using Terraform, I use Kubectl provider, within Terraform, to bootstrap ArgoCD with App of Apps Architecture. This way the project adhers to pure Gitops.
- **[Prometheus]:**
  Prometheus is deployed to the Kubernetes cluster using ArgoCD and is configured to scrape Kubernetes cluster metrics, Control plane metrics, Kubernetes nodes metrics, Pod metrics, Application metrics.
- **[Promtail and Loki]:**
  Loki is deployed to the Kubernetes cluster using ArgoCD. Loki is the main server, responsible for storing logs and processing queries. Promtail is deployed as a daemonset that runs on every node and is the agent responsible for gathering logs and sending them to Loki.
- **[Istio Service Mesh]:**
  Istio service mesh is deployed to the Kubernetes cluster again using ArgoCD. A service mesh is a dedicated infrastructure layer that you can add to your applications. It allows you to transparently add capabilities like observability, traffic management, and security, without adding them to your own code. Envoy sidecars are automatically injected into the all pods to enable black-box monitoring. This means we get 3 out of the four Golden Signals: Error Rate, Latency, and Throughput, without the overhead of instrumenting each application.
- **[Jaeger Distributed Tracing]:**
  Jaeger is configured to use monitoring enabled by Istio to surface Distributed Tracing.
- **[Grafana]:**
  Grafana is used to monitor application logs stored in Loki and visualize Kubernetes metrics scraped by Prometheus.

## Architecture

**Online Boutique** is composed of 11 microservices written in different
languages that talk to each other over gRPC.

[![Architecture of
microservices](/docs/img/architecture-diagram.png)](/docs/img/architecture-diagram.png)

**ArgoCD Architecture**
[![Architecture of
ArgoCD](https://www.cncf.io/wp-content/uploads/2022/08/image1-31.png)](https://www.cncf.io/wp-content/uploads/2022/08/image1-31.png)
**ArgoCD App of Apps Architecture**
[![Architecture of
ArgoCD App of Apps](https://argo-cd.readthedocs.io/en/stable/assets/application-of-applications.png)](https://argo-cd.readthedocs.io/en/stable/assets/application-of-applications.png)


**Overview of Microservices**

| Service                                              | Language      | Description                                                                                                                       |
| ---------------------------------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| [frontend](/src/frontend)                           | Go            | Exposes an HTTP server to serve the website. Does not require signup/login and generates session IDs for all users automatically. |
| [cartservice](/src/cartservice)                     | C#            | Stores the items in the user's shopping cart in Redis and retrieves it.                                                           |
| [productcatalogservice](/src/productcatalogservice) | Go            | Provides the list of products from a JSON file and ability to search products and get individual products.                        |
| [currencyservice](/src/currencyservice)             | Node.js       | Converts one money amount to another currency. Uses real values fetched from European Central Bank. It's the highest QPS service. |
| [paymentservice](/src/paymentservice)               | Node.js       | Charges the given credit card info (mock) with the given amount and returns a transaction ID.                                     |
| [shippingservice](/src/shippingservice)             | Go            | Gives shipping cost estimates based on the shopping cart. Ships items to the given address (mock)                                 |
| [emailservice](/src/emailservice)                   | Python        | Sends users an order confirmation email (mock).                                                                                   |
| [checkoutservice](/src/checkoutservice)             | Go            | Retrieves user cart, prepares order and orchestrates the payment, shipping and the email notification.                            |
| [recommendationservice](/src/recommendationservice) | Python        | Recommends other products based on what's given in the cart.                                                                      |
| [adservice](/src/adservice)                         | Java          | Provides text ads based on given context words.                                                                                   |
| [loadgenerator](/src/loadgenerator)                 | Python/Locust | Continuously sends requests imitating realistic user shopping flows to the frontend.                                              |

