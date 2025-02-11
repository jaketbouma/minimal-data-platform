# A minimal data platform
*202502 - Under construction*

Follow along as I implement the ideas in https://honestgrowth.super.site/essays/a-minimal-data-architecture .

Cloud accounts and multiaccount connections are deployed in https://github.com/jaketbouma/my-multicloud-ac


## Project outline

Designing and terraforming the [minimal data architecture](https://honestgrowth.super.site/essays/a-minimal-data-architecture) on multiple cloud platforms in parallel, to evaluate their openness, cost and feature coverage.

## Components in scope:

- **Storage**: Iceberg, Delta and Hudi on AWS S3 and Azure Storage
- **Metastores + Catalogs**: AWS Glue, Snowflake, Databricks Unity Catalog, Starburst, Polaris
- **IAM**: AWS IAM Identity Center, Azure Entra ID
- **Self service configuration**: Github yaml, [getport.io](http://getport.io) , Terraform Cloud

## Questions to answer:

- What can each component cover? What should each component cover?
- How well are Iceberg, Delta and Hudi supported?
- How mature are Terraform providers for the component, or are other declarative patterns recommended?