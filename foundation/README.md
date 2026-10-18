# Foundation

This directory contains Terraform-owned shared infrastructure foundation. The
Terraform root is [terraform/](terraform/), with reusable modules and separate
environment compositions.

Terraform owns the shared AWS network, EKS foundation, baseline platform IAM,
and their lifecycle. It does not own developer-requested resources exposed by
future Crossplane APIs.
