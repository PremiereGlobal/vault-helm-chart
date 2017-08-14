#!/bin/sh

echo "Linting Helm Chart"
helm lint ./helm_charts/vault
