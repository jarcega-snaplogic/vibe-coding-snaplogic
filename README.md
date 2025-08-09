# Vibe Coding SnapLogic

A comprehensive Claude Code-powered environment for SnapLogic pipeline development. This system combines intelligent validation, custom AI agents, MCP tools, and production-ready templates to create a sophisticated development workflow.

## 🎯 Overview

This toolkit addresses common SnapLogic development challenges:
- **Prevent invalid pipelines** from reaching repositories through automated validation
- **Leverage AI assistance** with specialized Claude Code agents for complex tasks
- **Standardize pipeline patterns** across projects using validated templates
- **Access real-time SnapLogic schemas** through MCP tool integration
- **Accelerate development** with contextual rule loading and best practices

## 🏗️ Architecture Overview

The system consists of integrated components that work together to provide a complete SnapLogic development environment:

```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│   Custom Agents     │    │     MCP Tools       │    │   Rules System      │
│   (Claude Code      │←──→│  (Real-time schema  │←──→│  (Knowledge base    │
│    automation)     │    │   access)           │    │   for agents)       │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
           │                           │                           │
           └─────────────────┬─────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Validation System                                    │
│  (Git hooks + comprehensive analysis tools)                                │
└─────────────────────────────────────────────────────────────────────────────┘
           │
┌─────────────────────────────────────────────────────────────────────────────┐
│                      Examples & Documentation                               │
│        (Production templates + comprehensive guides)                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 📁 Repository Structure

```
vibe-coding-snaplogic/
├── custom-agents/      # Claude Code custom agents (copy to ~/.claude/agents/)
├── mcp-tools/          # MCP server for SnapLogic schema access
├── rules/              # Modular knowledge base and development rules
├── validation/         # Git hooks and comprehensive validation tools
├── examples/           # Production-ready pipeline templates
├── docs/              # Architecture guides and documentation
└── README.md          # This file
```

## 🤖 Custom Agents Integration

This system includes two specialized Claude Code agents that automatically handle complex SnapLogic tasks:

### Setup Instructions
1. **Copy agents to Claude Code directory**:
   ```bash
   mkdir -p ~/.claude/agents/
   cp custom-agents/* ~/.claude/agents/
   ```

2. **Configure environment variables** (run `./setup-environment.sh`)

3. **Verify agent installation**:
   ```bash
   # In Claude Code, run:
   /agents
   ```

### Available Agents

#### `snaplogic-pipeline-developer`
**Automatically triggered for**: Pipeline creation, modification, field transformations, multi-snap workflows

**Capabilities**:
- Creates production-grade SnapLogic pipelines from scratch
- Modifies existing pipelines while maintaining compatibility
- Implements complex multi-snap workflows (Copy, Router, Union patterns)
- Configures field transformations and business logic
- Ensures Designer-friendly formatting and validation compliance
- Integrates with MCP tools for real-time schema access
- **Executes complete CI/CD workflow**: Automatically deploys validated pipelines from development to SnapLogic production
- **Manages deployment lifecycle**: Handles git commits, GitHub pushes, and SnapLogic synchronization seamlessly

#### `snaplogic-validation-troubleshooter`  
**Automatically triggered for**: Validation errors, JSON syntax issues, UUID conflicts, Designer problems

**Capabilities**:
- Systematic debugging of validation failures
- JSON syntax error remediation
- UUID consistency checking and repair
- Expression syntax validation and correction
- Multi-view snap configuration troubleshooting
- Integration with comprehensive validation tools

### Agent Features
- **Automatic Selection**: Claude Code chooses the right agent based on your request
- **Context-Aware Knowledge Loading**: Agents automatically load relevant rule files
- **MCP Tool Integration**: Direct access to SnapLogic schema validation
- **Rule Compliance**: All outputs follow comprehensive development standards

## 🔌 MCP Tools Integration

The system includes **two production-ready MCP servers** that provide real-time access to SnapLogic schemas, validation capabilities, and **automated CI/CD deployment**:

### Available MCP Tools

#### **SnapLogic Schema MCP (`mcp-snaplogic-schema`)**
Real-time access to SnapLogic snap schemas and validation capabilities.

#### **SnapLogic CI/CD MCP (`mcp-snaplogic-git`)** ⭐ **NEW** 
Automated development-to-production deployment with GitHub integration.

### CI/CD MCP Tools

#### `mcp__snaplogic-git__git_status`
Check synchronization status between GitHub and SnapLogic, showing which pipelines are out of sync.
- **Usage**: Monitor deployment status and identify pipelines needing sync
- **Output**: Detailed sync status with SHA comparisons and out-of-sync assets

#### `mcp__snaplogic-git__git_pull`
Pull latest changes from GitHub to SnapLogic, enabling **automated CI/CD deployment**.
- **Usage**: Deploy committed pipeline changes directly to SnapLogic production
- **Benefits**: Complete CI/CD automation - commit to GitHub, deploy to SnapLogic instantly
- **Integration**: Automatically used by `snaplogic-pipeline-developer` agent for seamless deployment

### Setup Instructions

#### **1. Install MCP Server Dependencies**
```bash
# Install schema MCP dependencies
cd mcp-tools/mcp-snaplogic-schema/
npm install

# Install CI/CD MCP dependencies  
cd ../mcp-snaplogic-git/
npm install
cd ../..
```

#### **2. Configure Environment Variables**
```bash
# Quick setup using provided script
./setup-environment.sh

# Or customize the setup-environment.sh script for your specific configuration
```

#### **3. Add to Claude Code MCP Configuration**
Edit `~/.claude/claude_desktop_config.json` or use the MCP configuration in your project directory:

```json
{
  "mcpServers": {
    "snaplogic-schema": {
      "command": "node",
      "args": ["/path/to/vibe-coding-snaplogic/mcp-tools/mcp-snaplogic-schema/index.js"]
    },
    "snaplogic-git": {
      "command": "node", 
      "args": ["/path/to/vibe-coding-snaplogic/mcp-tools/mcp-snaplogic-git/index.js"]
    }
  }
}
```

#### **4. Restart Claude Code**
Environment variables and MCP server configurations are loaded at startup.

### Available MCP Tools

#### `mcp__snaplogic-schema__search_snaps`
Search for SnapLogic snaps by name or description with optional category filtering.
```javascript
// Example usage
mcp__snaplogic-schema__search_snaps({
  query: "mapper",
  category: "transform"
})
```

#### `mcp__snaplogic-schema__list_categories`
Get all available snap categories (transform, flow, binary, etc.)

#### `mcp__snaplogic-schema__validate_snap_config`
Validate snap configurations against official SnapLogic schemas.
```javascript
// Example usage
mcp__snaplogic-schema__validate_snap_config({
  config: {
    class_id: "com-snaplogic-snaps-transform-datatransform",
    instance_id: "11111111-1111-1111-1111-000000000001",
    property_map: { /* snap properties */ }
  }
})
```

### MCP Features
- **Intelligent Caching**: Multi-index LRU cache for optimal performance
- **Smart Search**: Token-based search across snap names and descriptions  
- **Real-time Access**: Direct connection to SnapLogic API for current schemas
- **Error Handling**: Production-ready error handling and fallbacks
- **Integration Ready**: Designed for seamless Claude Code agent integration


## 📚 Rules & Knowledge System

The modular rules system provides contextual knowledge loading for specialized development scenarios:

### Rule Files
- **`snaplogic-pipeline-rules.md`**: Core pipeline structure, UUID patterns, architecture requirements
- **`snaplogic-snap-schemas.md`**: Snap-specific configurations and requirements
- **`field-transformation-rules.md`**: Business logic patterns and expression syntax
- **`validation-checklist.md`**: Systematic troubleshooting procedures

### Context-Sensitive Loading
The system automatically loads relevant rule files based on task context:
- **Pipeline Creation**: Load pipeline rules + snap schemas
- **Field Transformations**: Load transformation rules + expression patterns  
- **Validation Issues**: Load validation checklist + troubleshooting guides
- **Architecture Decisions**: Load pipeline patterns + best practices

## 🔍 Validation Tools

### Git Pre-Commit Hook
Fast, automatic validation that prevents invalid .slp files from being committed.

**Features**:
- ⚡ **<100ms validation** for typical pipelines
- 🎛️ **Two-stage validation**: JSON syntax → SnapLogic structure
- 🔧 **Helpful error messages** with remediation steps
- 🚫 **Blocks invalid commits** automatically
- ⚠️ **Emergency override**: `git commit --no-verify`

**Installation**:
```bash
cd your-snaplogic-repo
/path/to/vibe-coding-snaplogic/validation/install-hooks.sh
```

### Comprehensive Validation Script
Detailed validation with verbose output for development and debugging.

**Usage**:
```bash
# Basic validation
./validation/validate-slp.sh pipeline.slp

# Verbose output
./validation/validate-slp.sh -v pipeline.slp

# JSON output for automation
./validation/validate-slp.sh -j pipeline.slp | jq .
```

**Features**:
- 📊 **Detailed analysis** with performance metrics
- 🎨 **Color-coded output** for easy reading
- 📋 **JSON format** for automation integration
- ⚙️ **Configurable verbosity** levels

## 📖 Pipeline Examples

Production-ready templates for common SnapLogic patterns:

### 🔗 Two-Snap Pipeline
**Pattern**: Pipeline Execute → Mapper
- Pipeline chaining with transformations
- Phase-based development approach
- Clean data flow architecture

### 📄 Three-Snap Pipeline  
**Pattern**: File Reader → CSV Parser → Mapper
- CSV file processing workflows
- File-based data ingestion
- ETL with file sources

### 📊 Group By N Pipeline
**Pattern**: Pipeline Execute → Group By N
- Batch processing for AI/LLM integration
- Document aggregation and analysis
- Collect streaming data into batches

All examples are:
- ✅ **Validation compliant** - Pass all validation checks
- 🏭 **Production ready** - Include proper error handling
- 📚 **Well documented** - Clear usage instructions
- 🔧 **Easily customizable** - Template-based approach

## 📋 Validation Rules

### JSON Structure
- Valid JSON syntax with proper escaping
- Required SnapLogic pipeline fields
- Consistent UUID patterns and references

### Pipeline Architecture
- Correct snap/link relationships (n snaps = n-1 links)
- Proper view type compatibility (document/binary)
- Valid expression syntax with quoted string literals

### SnapLogic Specific
- Snap-specific required properties
- Multi-view snap configurations (Copy, Union, Join)
- Render map positioning for visual layout

See [validation/validation-rules.md](validation/validation-rules.md) for complete details.

## 🚀 Quick Start

### 1. Clone and Setup Repository
```bash
# Clone the vibe-coding-snaplogic repository
git clone https://github.com/jarcega-snaplogic/vibe-coding-snaplogic.git
cd vibe-coding-snaplogic
```

### 2. Install Custom Agents
```bash
# Copy agents to Claude Code directory
mkdir -p ~/.claude/agents/
cp custom-agents/* ~/.claude/agents/

# Verify in Claude Code
# Run: /agents
```

### 3. Setup Environment Variables
```bash
# Quick automated setup (recommended)
./setup-environment.sh

# Restart Claude Code after setup to load new environment
```

### 4. Setup MCP Tools (Optional)
```bash
# Install MCP server dependencies
cd mcp-tools/mcp-snaplogic-schema/
npm install
cd ../mcp-snaplogic-git/
npm install
cd ../..
```

### 5. Install Validation Hooks
```bash
# Install git pre-commit validation
./validation/install-hooks.sh
```

### 6. Start Developing
```bash
# Copy and customize a template
cp examples/2-snap-pipeline.slp MyNewPipeline.slp

# Validate your pipeline
./validation/validate-slp.sh MyNewPipeline.slp

# Commit with automatic validation
git add MyNewPipeline.slp  
git commit -m "Add new pipeline"  # Validation runs automatically
```

### 7. Leverage AI Assistance with CI/CD
```bash
# In Claude Code, create pipelines with full deployment automation:
# "Create a CSV processing pipeline that transforms customer data"
# → snaplogic-pipeline-developer agent:
#   1. Creates the pipeline with proper validation
#   2. Commits to git with descriptive message
#   3. Pushes to GitHub repository  
#   4. Automatically syncs to SnapLogic via CI/CD tools
#   5. Verifies deployment success

# "My pipeline has validation errors"  
# → snaplogic-validation-troubleshooter agent automatically debugs and fixes
```

## 🛠️ Development Workflow

**Simple agent-driven CI/CD process:**

1. **Create**: "Create a CSV processing pipeline" → `snaplogic-pipeline-developer` agent handles complete development-to-production workflow
2. **Debug**: "My pipeline has validation errors" → `snaplogic-validation-troubleshooter` agent fixes it  
3. **Validate**: Git hooks automatically check on commit
4. **Deploy**: Automated GitHub push and SnapLogic synchronization 
5. **Verify**: Automatic deployment confirmation via CI/CD tools

## 🔧 Installation Requirements

- **Python 3**: For JSON validation (`python3 -m json.tool`)
- **AWK**: For structure validation (typically pre-installed)
- **Bash**: For hook scripts
- **Git**: For hook integration
- **Node.js**: For MCP tools (optional)
- **SnapLogic Designer**: For testing (optional)

## 🤝 Contributing

### Adding New Examples
1. Follow existing UUID patterns (`11111111-1111-1111-1111-00000000000X`)
2. Include comprehensive documentation and use cases
3. Validate with all available tools
4. Update README with pattern description

### Improving Validation
1. Add new validation rules to AWK script
2. Test with diverse pipeline configurations
3. Maintain performance targets (<100ms)
4. Update documentation with new rules

### MCP Tool Development
1. Follow MCP protocol specifications
2. Integrate with existing validation infrastructure
3. Provide Claude Code compatible interfaces
4. Include comprehensive testing

## 📞 Support

### Getting Help
- **Validation Issues**: Check validation output for specific error messages
- **Hook Problems**: Run `./validation/install-hooks.sh` to reinstall
- **Example Usage**: See individual README files in examples/
- **Performance Issues**: Use verbose mode for detailed analysis

### Troubleshooting

#### Custom Agent Issues
- **Agents not appearing**: 
  ```bash
  # Verify agents are in correct location
  ls ../.claude/agents/
  # Should show: snaplogic-pipeline-developer.md, snaplogic-validation-troubleshooter.md
  ```
- **Agents not triggering**: Use manual invocation:
  ```
  "Use the snaplogic-pipeline-developer agent to create this pipeline"
  ```
- **Knowledge loading errors**: Verify rule files exist in `rules/` directory

#### MCP Tool Issues
- **Connection failures**: 
  ```bash
  # Test MCP server directly
  cd mcp-tools/mcp-snaplogic-schema/
  node index.js
  ```
- **Authentication errors**: Verify SnapLogic credentials in `.snaplogic-config.json`
- **Schema access issues**: Check SnapLogic API permissions and organization access

#### Validation Issues
- **Hook not running**: 
  ```bash
  # Reinstall validation hooks
  ./validation/install-hooks.sh
  # Check hook is executable
  ls -la .git/hooks/pre-commit
  ```
- **False positives**: Compare with working examples in `examples/` directory
- **Performance problems**: Use verbose mode for detailed analysis:
  ```bash
  ./validation/validate-slp.sh -v pipeline.slp
  ```

#### Pipeline Development Issues
- **UUID conflicts**: Use sequential pattern: `11111111-1111-1111-1111-00000000000X`
- **Expression syntax errors**: Always quote string literals: `"\"SELECT * FROM table\""`
- **Multi-view snap issues**: Ensure Copy snaps have minimum 2 output views
- **Designer import problems**: Check render_map configurations for visual layout

### Emergency Procedures
- **Bypass validation for emergency commits**: 
  ```bash
  git commit --no-verify -m "Emergency fix - validation bypassed"
  ```
- **Agent fallback**: Reference rule files directly if agents unavailable
- **MCP fallback**: Use validation scripts if MCP tools are down

### Getting Help
1. **Check validation output** for specific error messages and recommendations
2. **Compare with working examples** in the `examples/` directory
3. **Use comprehensive validation** with verbose output for detailed analysis
4. **Review rule files** in `rules/` directory for specific guidance
5. **Test with MCP tools** for real-time schema validation

### Reporting Issues
Please include:
- **System information**: OS, Node.js version, Claude Code version
- **Component affected**: Agent, MCP tool, validation, or pipeline development
- **Error output**: Complete error messages and stack traces
- **Steps to reproduce**: Detailed reproduction steps
- **Expected vs actual behavior**: Clear description of the issue
- **Pipeline files**: Sanitized .slp files if relevant to the issue

## 🆘 Getting Help

- **Validation errors**: Check output for specific fixes needed
- **Agent issues**: Verify agents are in `~/.claude/agents/` 
- **MCP problems**: Test server connection in `mcp-tools/`
- **Examples**: See `examples/` directory for working patterns

For detailed troubleshooting, see sections above on specific component issues.