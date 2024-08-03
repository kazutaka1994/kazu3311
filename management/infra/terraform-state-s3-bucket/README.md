rain fmt ./terraform-state-s3-bucket.yml
rain deploy ./terraform-state-s3-bucket.yml terraform-state-s3-bucket --params `cat .terraform-state-s3-bucket.param| tr -d "\n"`