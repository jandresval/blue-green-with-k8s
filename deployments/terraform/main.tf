provider "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "docker-desktop"
}

# Create 'webapp' deployment
resource "kubernetes_deployment_v1" "webapp" {
    metadata {
        name = "simple-webapp"
        labels = {
            app = "webapp" 
        }
    }

    spec {
        replicas = 2

        selector {
            match_labels = {
                app = "webapp"
            }
        }

        template {
            metadata {
                labels = {
                    app = "webapp"
                }
            }

            spec {
                container {
                    image = "jandresv/test:latest"
                    name  = "webapp"
                    port {
                        container_port = "8080"
                    }

                    resources {
                        limits = {
                            cpu    = "0.5"
                            memory = "512Mi"
                        }
                        requests = {
                            cpu    = "250m"
                            memory = "50Mi"
                        }
                    }

                    liveness_probe {
                        http_get {
                            path = "/"
                            port = 8080

                            http_header {
                                name  = "X-Custom-Header"
                                value = "Awesome"
                            }
                        }

                        initial_delay_seconds = 3
                        period_seconds        = 3
                    }
                }
            }
        }
    }
}

# Create 'webapp' service
resource "kubernetes_service" "webapp" {
    metadata {
        name = "simple-webapp"
    }
    spec {
        selector = {
            app = kubernetes_deployment_v1.webapp.metadata.0.labels.app
        }
        port {
            port        = 80
            target_port = 8080
        }
        type = "LoadBalancer"
    }

    depends_on = [
        kubernetes_deployment_v1.webapp
    ]
}