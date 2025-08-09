# Environment Variables Migration Documentation

## Current Working State (Before Migration)

### Development Directory Config Structure
**File**: `/home/jocel/llmapps/vibe-coding-snaplogic-new/.snaplogic-config.json`
```json
{
  "credentials": {
    "username": "jarcega@snaplogic.com",
    "password": "ORJAcon_01"
  },
  "schema_api": {
    "base_url": "https://prodeu-connectfasterinc-cloud-fm.emea.snaplogic.io",
    "org": "ConnectFasterInc"
  },
  "project_api": {
    "base_url": "https://emea.snaplogic.com",
    "org": "ConnectFasterInc",
    "project_space": "tryGit",
    "project_path": "snapLogic4snapLogic/tryGit",
    "project_id": "855493"
  }
}
```

### CI/CD Directory Config Structure  
**File**: `/home/jocel/llmapps/snaplogic_cicd_emea_cfi/.snaplogic-config.json`
```json
{
  "credentials": {
    "username": "jarcega@snaplogic.com",
    "password": "ORJAcon_01"
  },
  "api": {
    "base_url": "https://emea.snaplogic.com",
    "org": "ConnectFasterInc",
    "project_space": "tryGit",
    "project_id": "21818"
  }
}
```

## Standard Environment Variables Definition

Based on analysis of both config files and MCP tool requirements, here are the standard environment variables:

### **Required Environment Variables:**

```bash
# Authentication
export SNAPLOGIC_USERNAME="jarcega@snaplogic.com"
export SNAPLOGIC_PASSWORD="ORJAcon_01"

# Schema API (for MCP schema tool)
export SNAPLOGIC_SCHEMA_BASE_URL="https://prodeu-connectfasterinc-cloud-fm.emea.snaplogic.io"
export SNAPLOGIC_SCHEMA_ORG="ConnectFasterInc"

# Project API (for MCP git tool)
export SNAPLOGIC_PROJECT_BASE_URL="https://emea.snaplogic.com"
export SNAPLOGIC_PROJECT_ORG="ConnectFasterInc"
export SNAPLOGIC_PROJECT_SPACE="tryGit"
export SNAPLOGIC_PROJECT_ID="21818"
```

### **Optional/Computed Environment Variables:**
```bash
# Auto-computed project path
export SNAPLOGIC_PROJECT_PATH="snapLogic4snapLogic/${SNAPLOGIC_PROJECT_SPACE}"
```

## MCP Tool Configuration Changes Required

### Schema MCP Tool (`mcp-snaplogic-schema/index.js`)
**Current**: Expects `config.schema_api.base_url` and `config.schema_api.org`
**New**: Will use `process.env.SNAPLOGIC_SCHEMA_BASE_URL` and `process.env.SNAPLOGIC_SCHEMA_ORG`

### Git MCP Tool (`mcp-snaplogic-git/index.js`)  
**Current**: Expects `config.project_api.base_url`, `config.project_api.org`, etc.
**New**: Will use `process.env.SNAPLOGIC_PROJECT_BASE_URL`, `process.env.SNAPLOGIC_PROJECT_ORG`, etc.

## Conversion Script from Config File to Environment Variables

### Automatic Export Script
```bash
#!/bin/bash
# export_snaplogic_config.sh - Convert .snaplogic-config.json to environment variables

if [ ! -f ".snaplogic-config.json" ]; then
    echo "Error: .snaplogic-config.json not found in current directory"
    exit 1
fi

# Extract and export values using jq
export SNAPLOGIC_USERNAME="$(jq -r '.credentials.username // ""' .snaplogic-config.json)"
export SNAPLOGIC_PASSWORD="$(jq -r '.credentials.password // ""' .snaplogic-config.json)"

# Schema API (try both .schema_api and .api structures)
export SNAPLOGIC_SCHEMA_BASE_URL="$(jq -r '.schema_api.base_url // .api.base_url // ""' .snaplogic-config.json)"
export SNAPLOGIC_SCHEMA_ORG="$(jq -r '.schema_api.org // .api.org // ""' .snaplogic-config.json)"

# Project API (try both .project_api and .api structures) 
export SNAPLOGIC_PROJECT_BASE_URL="$(jq -r '.project_api.base_url // .api.base_url // ""' .snaplogic-config.json)"
export SNAPLOGIC_PROJECT_ORG="$(jq -r '.project_api.org // .api.org // ""' .snaplogic-config.json)"
export SNAPLOGIC_PROJECT_SPACE="$(jq -r '.project_api.project_space // .api.project_space // ""' .snaplogic-config.json)"
export SNAPLOGIC_PROJECT_ID="$(jq -r '.project_api.project_id // .api.project_id // ""' .snaplogic-config.json)"

# Compute project path
export SNAPLOGIC_PROJECT_PATH="snapLogic4snapLogic/${SNAPLOGIC_PROJECT_SPACE}"

echo "✅ SnapLogic environment variables exported successfully"
echo "Schema API: ${SNAPLOGIC_SCHEMA_BASE_URL}"
echo "Project API: ${SNAPLOGIC_PROJECT_BASE_URL}"
echo "Project: ${SNAPLOGIC_PROJECT_ORG}/${SNAPLOGIC_PROJECT_SPACE}"
```

### Manual Export Commands
```bash
# For CI/CD directory with .api structure:
export SNAPLOGIC_USERNAME="$(jq -r '.credentials.username' .snaplogic-config.json)"
export SNAPLOGIC_PASSWORD="$(jq -r '.credentials.password' .snaplogic-config.json)"
export SNAPLOGIC_SCHEMA_BASE_URL="https://prodeu-connectfasterinc-cloud-fm.emea.snaplogic.io"
export SNAPLOGIC_SCHEMA_ORG="ConnectFasterInc"
export SNAPLOGIC_PROJECT_BASE_URL="$(jq -r '.api.base_url' .snaplogic-config.json)"
export SNAPLOGIC_PROJECT_ORG="$(jq -r '.api.org' .snaplogic-config.json)"
export SNAPLOGIC_PROJECT_SPACE="$(jq -r '.api.project_space' .snaplogic-config.json)"
export SNAPLOGIC_PROJECT_ID="$(jq -r '.api.project_id' .snaplogic-config.json)"
export SNAPLOGIC_PROJECT_PATH="snapLogic4snapLogic/${SNAPLOGIC_PROJECT_SPACE}"
```

## Benefits of This Approach

1. **Location Independence**: MCP tools work regardless of working directory
2. **Industry Standard**: Follows Twelve-Factor App methodology  
3. **Security**: Credentials managed through environment, not files
4. **Simplicity**: No complex config file parsing logic
5. **Portability**: Easy for others to configure their environments
6. **Consistency**: Same environment variables work across all projects

## Migration Steps Summary

1. ✅ **Phase 1 Complete**: Backups created, rollback point tagged, MCP tools version controlled
2. **Phase 2 Current**: Define environment variables and update CLAUDE.md
3. **Phase 2 Next**: Simplify MCP tools to use only environment variables
4. **Phase 3**: Test and validate the environment variable approach