test-local:
  bluebuild rebase --tempdir /var/tmp recipes/recipe.yml

generate-iso:
  sudo bluebuild generate-iso --iso-name blue95-latest.iso image ghcr.io/ledif/blue95:latest
