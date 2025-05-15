# AWS ECS Fargate Deployment with CI/CD Pipeline


A production-ready infrastructure deployment for a containerized web application using AWS ECS Fargate with Jenkins CI/CD automation.

## Key Features
- **Infrastructure as Code**: Full AWS environment provisioning via Terraform
- **CI/CD Pipeline**: Jenkins automation with manual approval gates
- **Load Balanced Architecture**: Application Load Balancer with health checks
- **Observability**: CloudWatch logging & metric monitoring
- **Security**: IAM roles with least privilege principles

## Technical Components
| Category          | AWS Resources/Tools                       |
|--------------------|-------------------------------------------|
| Networking        | VPC, Public Subnets, Internet Gateway     |
| Compute           | ECS Fargate Cluster & Service             |
| Load Balancing    | Application Load Balancer (ALB)           |
| Security          | Security Groups, IAM Roles                |
| Monitoring        | CloudWatch Logs & Alarms                  |
| CI/CD             | Jenkins Pipeline                          |

## Project Structure


## Deployment Workflow
1. **Terraform Initialize**  
   `terraform init`  
2. **Plan Infrastructure**  
   `terraform plan -out=tfplan`  
3. **Apply Configuration**  
   `terraform apply tfplan`  
4. **Jenkins Pipeline**
   - Automatic SCM polling every 5 minutes. But I prefer to use Git Action or Webhook rather than polling.
   - Manual approval before production deployment
   - Integration testing post-deployment

## Monitoring Implementation
- **CloudWatch Logs**:  
  ECS task logs stored in `/ecs/hello-world-task` log group
- **Metric Alarms**:
  - CPU Utilization >80%
  - Memory Utilization >80%

## Security Implementation
I use full acess policy due to time limit. But it would be better give a limitation.
- IAM execution role with:
  - `AmazonECSTaskExecutionRolePolicy`
  - `CloudWatchLogsFullAccess`
- Security group rules:
  - ALB: HTTP ingress from anywhere
  - ECS: Restricted ingress from ALB only
- Credential masking in Jenkins pipeline


