#!/bin/bash

# SnapLogic Environment Setup Script
# Automatically configures environment variables for SnapLogic MCP tools and agents

echo "🚀 SnapLogic Environment Setup"
echo "=============================="

# Detect shell profile
if [[ "$SHELL" == *"zsh"* ]]; then
    PROFILE="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [[ "$SHELL" == *"bash"* ]]; then
    PROFILE="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    PROFILE="$HOME/.profile"
    SHELL_NAME="profile"
fi

echo "📋 Detected shell: $SHELL_NAME"
echo "📄 Profile file: $PROFILE"
echo ""

# Check if already configured
if grep -q "SnapLogic MCP Tools Configuration" "$PROFILE"; then
    echo "⚠️  SnapLogic environment variables already configured in $PROFILE"
    echo "💡 To reconfigure, manually remove the existing section first"
    exit 0
fi

# Add environment variables to profile
echo "✅ Adding SnapLogic environment variables to $PROFILE..."

cat >> "$PROFILE" << 'EOF'

# SnapLogic MCP Tools Configuration
# These environment variables are required for Claude Code's SnapLogic MCP tools to function
export SNAPLOGIC_USERNAME="jarcega@snaplogic.com"
export SNAPLOGIC_PASSWORD="ORJAcon_01"
export SNAPLOGIC_SCHEMA_BASE_URL="https://emea.snaplogic.com"
export SNAPLOGIC_SCHEMA_ORG="ConnectFasterInc"
export SNAPLOGIC_PROJECT_BASE_URL="https://emea.snaplogic.com"
export SNAPLOGIC_PROJECT_ORG="ConnectFasterInc"
export SNAPLOGIC_PROJECT_SPACE="tryGit"
export SNAPLOGIC_PROJECT_ID="21818"
export SNAPLOGIC_PROJECT_PATH="snapLogic4snapLogic/tryGit"
EOF

echo "✅ Environment variables added successfully!"
echo ""

# Load the new environment
echo "🔄 Loading new environment variables..."
source "$PROFILE"

# Verify configuration
echo "🔍 Verifying configuration..."
echo "Username: $SNAPLOGIC_USERNAME"
echo "Schema URL: $SNAPLOGIC_SCHEMA_BASE_URL"
echo "Project Space: $SNAPLOGIC_PROJECT_SPACE"
echo ""

echo "🎉 Setup Complete!"
echo ""
echo "📝 Next Steps:"
echo "1. Restart Claude Code to pick up the new environment variables"
echo "2. Test MCP tool connectivity"
echo "3. Start using SnapLogic agents for pipeline development"
echo ""
echo "⚠️  Important: If you change environment variables, restart Claude Code"
echo ""
echo "💡 To customize for your environment:"
echo "   - Edit $PROFILE"
echo "   - Update SNAPLOGIC_USERNAME, SNAPLOGIC_PASSWORD, etc."
echo "   - Run: source $PROFILE"
echo "   - Restart Claude Code"