This repository is responsible for creation of GCP cloud run v2 job and a cloud scheduler to excecute the same on given amount of time.
Only changes that are required to be done at terraform.tfvars.
It is requiring a special GCP beta provider as standard provider does not support the scheduler on GCP cloud run job