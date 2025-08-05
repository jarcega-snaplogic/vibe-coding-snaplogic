# MCP SnapLogic Schema Server Documentation

## Overview

The MCP SnapLogic Schema Server is a Model Context Protocol (MCP) tool that provides intelligent access to SnapLogic snap schemas with smart caching. It connects to the SnapLogic API to fetch snap catalog information and provides search, schema retrieval, and validation capabilities for SnapLogic pipeline development.

## Features

- **Intelligent Caching**: Multi-index caching system with LRU eviction for optimal memory usage
- **Smart Search**: Token-based search across snap names and descriptions
- **Category Filtering**: Organize snaps by categories (transform, flow, binary, etc.)
- **Schema Validation**: Basic validation of snap configurations
- **Production Ready**: Built for enterprise reliability with proper error handling

## Prerequisites

- Node.js >= 16.0.0
- Claude Code with MCP support
- SnapLogic credentials with API access
- Active SnapLogic organization access

## Installation & Setup

### 1. Install Dependencies

```bash
cd mcp-snaplogic-schema
npm install
```

### 2. Configure SnapLogic Credentials

Create `.snaplogic-config.json` in your project root:

```json
{
  "credentials": {
    "username": "your.email@company.com",
    "password": "your_password"
  },
  "api": {
    "base_url": "https://emea.snaplogic.com",
    "org": "YourOrgName",
    "project_space": "your_project_space",
    "project_id": "12345"
  },
  "sync": {
    "auto_commit": true,
    "commit_prefix": "[SnapLogic Sync]",
    "validate_before_push": true
  }
}
```

### 3. Configure Claude Code MCP

Add to your Claude Code MCP settings (`~/.claude/mcp_servers.json`):

```json
{
  "snaplogic-schema": {
    "command": "node",
    "args": ["index.js"],
    "cwd": "/path/to/your/mcp-snaplogic-schema"
  }
}
```

### 4. Restart Claude Code

After configuration, restart Claude Code to load the MCP server:

```bash
# If you're using systemd or similar, restart the service
# Otherwise, exit and restart your Claude Code session
```

## API Functions

### 1. Search Snaps

Find SnapLogic snaps by name or description:

```javascript
mcp__snaplogic-schema__search_snaps({
  query: "mapper",           // Required: search term
  category: "transform"      // Optional: filter by category
})
```

**Example Response:**
```json
[
  {
    "class_id": "com-snaplogic-snaps-transform-datatransform",
    "name": "Mapper",
    "category": "transform",
    "description": "Transform data using expressions",
    "version": 2
  }
]
```

### 2. Get Snap Schema

Retrieve detailed schema for a specific snap:

```javascript
mcp__snaplogic-schema__get_snap_schema({
  class_id: "com-snaplogic-snaps-transform-datatransform"
})
```

**Example Response:**
```json
{
  "class_id": "com-snaplogic-snaps-transform-datatransform",
  "class_version": 2,
  "description": "Transform data using expressions",
  "property_map": {
    "settings": {
      "execution_mode": { "value": "Validate & Execute" }
    },
    "info": {
      "label": { "value": "Mapper" }
    }
  }
}
```

### 3. List Categories

Get all available snap categories:

```javascript
mcp__snaplogic-schema__list_categories()
```

**Example Response:**
```json
[
  {
    "name": "transform",
    "count": 15
  },
  {
    "name": "flow",
    "count": 8
  },
  {
    "name": "binary",
    "count": 12
  }
]
```

### 4. Validate Snap Configuration

Validate a snap configuration against its schema:

```javascript
mcp__snaplogic-schema__validate_snap_config({
  config: {
    "class_id": "com-snaplogic-snaps-transform-datatransform",
    "instance_id": "12345678-1234-1234-1234-123456789012",
    "property_map": {
      "settings": {
        "execution_mode": { "value": "Validate & Execute" }
      }
    }
  }
})
```

**Example Response:**
```json
{
  "valid": true,
  "errors": [],
  "warnings": []
}
```

## Usage Examples

### Basic Snap Search

```javascript
// Search for mapper snaps
const results = await mcp__snaplogic_schema__search_snaps({
  query: "mapper"
});

// Search within specific category
const transformSnaps = await mcp__snaplogic_schema__search_snaps({
  query: "data",
  category: "transform"
});
```

### Building Pipeline Configurations

```javascript
// 1. Find the snap you need
const mappers = await mcp__snaplogic_schema__search_snaps({
  query: "mapper"
});

// 2. Get detailed schema
const mapperSchema = await mcp__snaplogic_schema__get_snap_schema({
  class_id: mappers[0].class_id
});

// 3. Validate your configuration
const validation = await mcp__snaplogic_schema__validate_snap_config({
  config: {
    class_id: mappers[0].class_id,
    instance_id: "12345678-1234-1234-1234-123456789012",
    property_map: {
      settings: {
        execution_mode: { value: "Validate & Execute" }
      }
    }
  }
});
```

### Integration with Pipeline Development

```javascript
// Use with SnapLogic pipeline development agent
// The agent can automatically search and validate snaps
const agent = new Task({
  description: "Create data pipeline",
  prompt: `Create a pipeline that:
    1. Reads CSV data
    2. Transforms fields using Mapper
    3. Outputs to JSON
    
    Use MCP SnapLogic Schema tool to find appropriate snaps.`,
  subagent_type: "snaplogic-pipeline-developer"
});
```

## Architecture Details

### Caching System

The tool implements a sophisticated caching system:

- **Catalog Cache**: Stores compact snap information for 24 hours
- **Search Index**: Token-based search index for fast lookups
- **Category Index**: Organized by snap categories
- **Full Schema Cache**: LRU cache for detailed schemas (limit: 50 items)

### API Integration

- **Base URL**: Configurable SnapLogic API endpoint
- **Authentication**: Basic Auth using username/password
- **Rate Limiting**: Intelligent caching reduces API calls
- **Error Handling**: Comprehensive error handling with meaningful messages

### Performance Optimizations

- **Memory Efficient**: Only essential fields stored in catalog
- **Fast Search**: Pre-built token indexes for sub-second search
- **Smart Loading**: Lazy loading of full schemas only when needed
- **Cache Invalidation**: Automatic cache refresh after 24 hours

## Troubleshooting

### Common Issues

1. **"snapPackData is not iterable" Error**
   - **Cause**: API response structure mismatch
   - **Fix**: Ensure the cache.js processCatalog method handles the correct response format
   - **Note**: This has been fixed in the latest version

2. **Authentication Failures**
   - **Cause**: Incorrect credentials or expired passwords
   - **Fix**: Verify `.snaplogic-config.json` credentials
   - **Check**: Test credentials via SnapLogic Designer login

3. **Empty Search Results**
   - **Cause**: Cache not loaded or API connectivity issues
   - **Fix**: Restart MCP server, check network connectivity
   - **Debug**: Check debug logs for API errors

4. **MCP Server Not Starting**
   - **Cause**: Missing dependencies or configuration
   - **Fix**: Run `npm install` and verify all paths are correct
   - **Check**: Ensure Node.js version >= 16.0.0

### Debug Mode

Enable debug mode by running:

```bash
cd mcp-snaplogic-schema
node debug-api.js
```

This will test the API connection and save the response structure to `debug-response.json`.

### Server Restart After Reboot

If you need to restart the MCP server after a system reboot:

1. **Restart Claude Code**: Exit and restart your Claude Code session
2. **Check MCP Status**: Verify MCP servers are loaded with `/mcp` command
3. **Test Connection**: Try a simple search to verify functionality
4. **Rebuild Cache**: The server will automatically fetch fresh catalog data

## Integration with SnapLogic Development Workflow

### With Custom Agents

The MCP tool integrates seamlessly with Claude Code's custom agents:

```javascript
// Automatic agent selection for pipeline tasks
"Create a pipeline with CSV Reader, Mapper, and File Writer"
// → snaplogic-pipeline-developer agent uses MCP tools automatically

// Manual agent invocation
"Use the snaplogic-pipeline-developer agent to create this pipeline"
// → Agent has full access to MCP SnapLogic Schema tools
```

### With Validation Workflow

```bash
# 1. Develop pipeline using MCP tools
# 2. Validate with git hooks
git commit -m "Add data transformation pipeline"

# 3. Git hooks automatically validate using MCP validation
# 4. Push only if validation passes
git push origin main
```

## Best Practices

1. **Cache Management**: Let the tool manage caching automatically
2. **Search Strategy**: Use specific terms for better results
3. **Schema Validation**: Always validate configurations before deployment
4. **Error Handling**: Check validation results before using configurations
5. **Security**: Keep credentials secure, use environment variables in production

## Contributing

### Development Setup

```bash
# Clone and setup
git clone [repository-url]
cd mcp-snaplogic-schema
npm install

# Test changes
node debug-api.js
npm test
```

### Code Structure

- `index.js`: Main MCP server implementation
- `cache.js`: Intelligent caching system
- `debug-api.js`: API testing utility
- `package.json`: Dependencies and metadata

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions:
1. Check troubleshooting section above
2. Review debug logs and API responses
3. Verify SnapLogic API access and credentials
4. Test with minimal configuration first

---

**🎉 Ready for Production-Grade SnapLogic Development**

*The MCP SnapLogic Schema Server provides intelligent snap discovery and validation for enterprise SnapLogic development workflows.*