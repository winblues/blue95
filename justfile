test-local:
  #!/bin/bash
  set -xeuo pipefail

  bluebuild rebase --tempdir /var/tmp recipes/recipe.yml
