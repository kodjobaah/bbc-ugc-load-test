#!/bin/bash
aws ecr get-login-password --region eu-west-3 | docker login --username AWS --password-stdin 625194385885.dkr.ecr.eu-west-3.amazonaws.com

