### Initial Setup
- Edit project.godot file and change the value of config/name (this is what it shows up as in the Godot launcher)

### Itch.io Setup
- Create API key at https://itch.io/user/settings/api-keys
  - Needed for the CI/CD pipeline
- Create a new project at https://itch.io/game/new
  - Kind of project: HTML
  - Pricing: No payments
  - Width: 1280
  - Height: 720
- After the first time the pipeline has deployed the game (only available after first upload):
  - On the game's profile page created earlier under Uploads
  - ✅ "This file will be played in the browser"
  - Save

### CI/CD Setup
- Edit .github/workflows/deploy.yml and set:
  - GODOT_VERSION
  - ITCHIO_USERNAME
  - ITCHIO_GAME
- Create the ITCHIO_API_KEY secret
  - Settings -> Security -> Secrets and variables -> Actions -> Repository secrets