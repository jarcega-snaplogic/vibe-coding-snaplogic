# SnapLogic Snap Configuration Schemas

Comprehensive snap-specific configuration patterns, required properties, and best practices. Load this file when configuring specific snap types or troubleshooting snap-related issues.

## 🔧 Essential Snap Categories

### Transform Snaps

#### Mapper (Data Transform) - `com-snaplogic-snaps-transform-datatransform`
**Critical Configuration**:
```json
{
    "class_version": 4,
    "settings": {
        "execution_mode": {"value": "Validate & Execute"},
        "nullSafeAccess": {"value": true},           // ALWAYS true
        "passThrough": {"value": false},             // Usually false
        "transformations": {
            "value": {
                "mappingRoot": {"value": "$"},
                "mappingTable": {"value": [...]}
            }
        }
    }
}
```

**Mapping Table Format**:
```json
{
    "expression": {
        "expression": true,
        "value": "$source_field"
    },
    "targetPath": {
        "value": "target_field"
    }
}
```

#### Group By N - `com-snaplogic-snaps-transform-groupbyn`
**Complete Required Configuration**:
```json
{
    "class_version": 1,
    "settings": {
        "execution_mode": {"value": "Validate & Execute"},
        "flushTimeoutSecs": {"value": 0},
        "groupSize": {"value": 0},                   // 0 = collect all
        "memorySensitivity": {"value": "None"},
        "minGroupSize": {"value": 1},
        "minimumMemory": {"value": 1073741824},
        "outOfResourceTimeout": {"value": 30},
        "targetField": {"value": "documents"}        // Array field name
    }
}
```

**Usage Patterns**:
- **groupSize: 0** - Collect all documents (most common)
- **targetField** - Choose descriptive name ("orders", "records", "data")
- **Memory Settings** - Use defaults unless specific requirements

#### CSV Parser - `com-snaplogic-snaps-transform-csvparser`
**Standard Configuration**:
```json
{
    "class_version": 3,
    "settings": {
        "charset": {"value": "Auto BOM detect"},
        "containsHeader": {"value": true},
        "delimiter": {"expression": false, "value": ";"},  // Common for EU data
        "errorPolicy": {"value": "Both"},
        "escapeChar": {"expression": false, "value": "\\"},
        "execution_mode": {"value": "Validate & Execute"},
        "ignoreEmptyData": {"value": true},
        "quoteCharacter": {"expression": false, "value": "\""},
        "skipLines": {"expression": false, "value": 0},
        "validateHeaders": {"value": false}
    }
}
```

### Flow Control Snaps

#### Pipeline Execute - `com-snaplogic-snaps-flow-pipeexec`
**Standard Configuration**:
```json
{
    "class_version": 1,
    "settings": {
        "execution_mode": {"value": "Validate & Execute"},
        "pipeline": {"expression": false, "value": "PipelineName"},
        "poolSize": {"value": 1},
        "reuse": {"value": false},
        "timeout": {"value": 0}                      // 0 = no timeout
    }
}
```

#### Copy Snap - `com-snaplogic-snaps-flow-copy`
**CRITICAL**: Requires minimum 2 output views and render_map configuration
```json
{
    "output": {
        "output0": {"label": {"value": "output0"}, "view_type": {"value": "document"}},
        "output1": {"label": {"value": "output1"}, "view_type": {"value": "document"}}
    }
}
```

**Required Render Map**:
```json
{
    "render_map": {
        "detail_map": {
            "snap_id": {
                "output": {
                    "output1": {
                        "dx_int": 0,
                        "dy_int": 1,
                        "rot_int": 0
                    }
                }
            }
        }
    }
}
```

### File Operations

#### File Reader - `com-snaplogic-snaps-binary-simpleread`
**SLDB Configuration**:
```json
{
    "class_version": 1,
    "settings": {
        "advancedProperties": {"value": []},
        "enableStaging": {"value": false},
        "executeDuringPreview": {"value": true},
        "execution_mode": {"value": "Validate & Execute"},
        "filePath": {"expression": false, "value": "filename.csv"},  // SLDB path
        "outputHeaders": {"value": []},
        "preventURLEncoding": {"value": false},
        "retries": {"expression": false, "value": 0},
        "retryInterval": {"expression": false, "value": 1}
    }
}
```

#### File Writer - `com-snaplogic-snaps-binary-write`
**CRITICAL**: Requires binary input, not document
```json
{
    "class_version": 3,
    "settings": {
        "createDir": {"value": true},
        "execution_mode": {"value": "Execute only"},
        "fileAction": {"value": "OVERWRITE"},
        "filename": {"expression": true, "value": "\"output.json\""},
        "validate": {"value": true},
        "writeEmptyFile": {"value": false},
        "writeHeader": {"value": false}
    }
}
```

**File Path Rules**:
- **SLDB**: Use filename only (`"report.csv"`)
- **Full Path**: Use absolute paths when needed (`"/tmp/report.csv"`)
- **Dynamic**: Use expressions for generated names

### AI/ML Integration

#### AWS Bedrock Converse API
**System Prompt Configuration**:
```json
{
    "systemPrompt": {
        "expression": false,                         // For static text
        "value": "You are an expert analyst."
    }
}
```

**Prompt Mode Patterns**:
- **Simple Mode**: `advancedMode: false` → `useMessages: false`, reference `$prompt`
- **Advanced Mode**: `advancedMode: true` → `useMessages: true`, reference `$messages`

#### Document to Binary Conversion
**Required for AI → File Writer**:
```json
{
    "class_id": "com-snaplogic-snaps-transform-documenttobinary",
    "settings": {
        "execution_mode": {"value": "Validate & Execute"}
    }
}
```

**Pattern**: AI/LLM → [Mapper] → Document to Binary → File Writer

## 📏 Expression Syntax Rules

### String Literals (CRITICAL)
- **Always Quote**: All string literals must be wrapped in double quotes
- **Concatenation**: Quote each segment separately
- **Escaping**: Proper backslash escaping for special characters

#### Correct Examples:
```json
"value": "\"SELECT * FROM Table WHERE id = \" + $id"
"value": "$field != null && $field.length() > 35 ? $field.substring(0, 35) : $field"
"value": "\"Error: \" + $error + \" at \" + Date.now().toString()"
```

#### Common Errors:
```json
// ❌ Wrong - unquoted string
"value": "SELECT * FROM Table WHERE id = " + $id

// ❌ Wrong - missing quotes in ternary
"value": "$field ? $field : default"

// ❌ Wrong - JavaScript method
"value": "Date.now().toISOString()"
```

### Parameter References
- **Pipeline Parameters**: Use underscore prefix (`_parameterName`)
- **Document Fields**: Use dollar prefix (`$fieldName`)
- **Array Data**: Use mustache in prompts (`{{$arrayName}}`)

### Date Functions
- **SnapLogic Compatible**: `Date.now().toLocaleDateString()`
- **Avoid JavaScript**: Don't use `.toISOString()`, `.substring()` on dates

## 🔍 Multi-View Snap Requirements

### Snaps with Multiple Output Views
- **Copy**: Minimum 2 outputs (output0, output1)
- **Router**: Multiple outputs based on conditions
- **Diff**: Multiple outputs for comparison results

### Snaps with Multiple Input Views  
- **Union**: Minimum 2 inputs (combine streams)
- **Join**: 2 inputs (left, right for relational operations)

### Render Map Requirement
**CRITICAL**: Multi-output snaps need render_map configuration or only first output appears in Designer.

## 🎨 Generator Snap Content Formatting

### CSV Generator
```json
{
    "editable_content": {
        "value": "Header1,Header2,Header3\nValue1,Value2,Value3\nValue4,Value5,Value6"
    }
}
```

### JSON Generator  
```json
{
    "editable_content": {
        "value": "[\n  {\n    \"field\": \"value\"\n  }\n]"
    }
}
```

**CRITICAL**: Use actual newlines (`\n`), not escaped sequences (`\\n`).

## 📋 Common Configuration Patterns

### Development vs Production
- **Development**: `"execution_mode": "Validate & Execute"`
- **Production**: `"execution_mode": "Execute only"`

### Error Handling
- **Fail Fast**: `"error_behavior": "fail"`
- **Continue Processing**: `"error_behavior": "continue"`
- **Ignore Errors**: `"error_behavior": "ignore"`

### Account References
```json
{
    "account": {
        "account_ref": {"value": {}}
    }
}
```

## 🚨 Critical Validation Points

### Before Using Any Snap
1. **Check class_version** - Use latest compatible version
2. **Include all required properties** - Reference working examples
3. **Set proper view_types** - Match input/output compatibility
4. **Configure error handling** - Based on business requirements

### Common Snap Errors
- **Missing Properties**: Use vibe-coding-snaplogic examples as reference
- **Wrong View Types**: Binary/Document mismatch
- **Expression Errors**: Unquoted string literals
- **Multi-View Issues**: Missing outputs or render_map configuration

---

**Reference**: Always compare with working examples in vibe-coding-snaplogic/examples/ when configuring snaps.