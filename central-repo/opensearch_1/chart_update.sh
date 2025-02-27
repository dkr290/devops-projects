
#!/bin/bash

# Update dependencies for the main chart
echo "Updating dependencies for the main chart..."
helm dependency update

# Find all subcharts inside 'charts/' and update their dependencies
for dir in charts/*/; do
  if [ -f "$dir/Chart.yaml" ]; then
    echo "Updating dependencies for $dir..."
    (cd "$dir" && helm dependency update)
  fi
done

echo "All dependencies updated successfully!"
