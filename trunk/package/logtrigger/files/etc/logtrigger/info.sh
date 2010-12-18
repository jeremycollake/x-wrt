#!/bin/sh
ENV=$(env)
echo "$ENV" | sed -n '/^LT/p'
echo ""
