test-local:
  #!/bin/bash
  set -xeuo pipefail

  bluebuild rebase recipes/recipe.yml

  #bluebuild generate -o Containerfile recipes/recipe.yml
  #sudo podman build -f Containerfile -t blue95-local
  #sudo bootc switch --transport containers-storage localhost/blue95-local
