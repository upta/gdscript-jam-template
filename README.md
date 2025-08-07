### Initial Setup
- Edit project.godot file and change the value of config/name (this is what it shows up as in the Godot launcher)

### CI/CD Setup
- Edit .github/workflows/deploy.yml and set:
  - GODOT_VERSION
  - ITCHIO_USERNAME
  - ITCHIO_GAME
- Create the ITCHIO_API_KEY secret
  - Settings -> Security -> Secrets and variables -> Actions -> Repository secrets