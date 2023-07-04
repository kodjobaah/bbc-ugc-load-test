#/bin/bash

npm install
yarn build
kubectl cp build control/admin-controller:/home/control
