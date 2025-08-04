# SnapLogic Pipeline Validation Rules

Comprehensive validation rules for SnapLogic pipeline (.slp) files to prevent invalid configurations and ensure proper pipeline structure.

## JSON Structure Validation

### Required Fields
Every SnapLogic pipeline must contain:
- `class_id`: Must be `"com-snaplogic-pipeline"`
- `class_version`: Pipeline version (typically 9)
- `property_map`: Pipeline metadata and configuration
- `snap_map`: Individual snap configurations
- `link_map`: Connections between snaps (if multiple snaps)
- `render_map`: Visual layout information

### JSON Syntax Requirements
- **Valid JSON**: No trailing commas, proper quote escaping
- **String Literals**: All string literals in expressions must be double-quoted
- **Expression Syntax**: Follow SnapLogic expression format
  ```json
  "value": "\"String literal\" + $variable + \"another literal\""
  ```

## Pipeline Structure Validation

### Snap/Link Relationship
- **Single Snap**: 0 links (no connections needed)
- **Multiple Snaps**: n snaps require (n-1) links
- **Linear Flow**: Each snap connects to the next in sequence
- **Branching**: Use Copy snap with multiple outputs

### UUID Consistency
- **Pattern**: `11111111-1111-1111-1111-############` (12 digits)
- **Sequential**: Use incremental pattern (000000000000, 000000000001, etc.)
- **Consistency**: All UUIDs in `link_map` must exist in `snap_map`
- **Uniqueness**: Each snap must have unique UUID

## Snap Configuration Validation

### Required Snap Properties
All snaps must include:
- `class_id`: Snap type identifier
- `class_version`: Snap version
- `instance_id`: Must match snap_map key
- `property_map`: Snap configuration
- `view_serial`: Typically 100

### Common Snap Patterns

#### Mapper Snap (`com-snaplogic-snaps-transform-datatransform`)
```json
"settings": {
    "execution_mode": {"value": "Validate & Execute"},
    "nullSafeAccess": {"value": true},
    "passThrough": {"value": false},
    "transformations": {
        "value": {
            "mappingRoot": {"value": "$"},
            "mappingTable": {"value": [...]}
        }
    }
}
```

#### Group By N Snap (`com-snaplogic-snaps-transform-groupbyn`)
```json
"settings": {
    "execution_mode": {"value": "Validate & Execute"},
    "flushTimeoutSecs": {"value": 0},
    "groupSize": {"value": 0},
    "memorySensitivity": {"value": "None"},
    "minGroupSize": {"value": 1},
    "minimumMemory": {"value": 1073741824},
    "outOfResourceTimeout": {"value": 30},
    "targetField": {"value": "field_name"}
}
```

#### Pipeline Execute Snap (`com-snaplogic-snaps-flow-pipeexec`)
```json
"settings": {
    "execution_mode": {"value": "Validate & Execute"},
    "pipeline": {"expression": false, "value": "PipelineName"},
    "poolSize": {"value": 1},
    "reuse": {"value": false},
    "timeout": {"value": 0}
}
```

## View Type Validation

### Input/Output Compatibility
- **Document → Document**: Standard data flow
- **Binary → Document**: Use parser snaps (CSV Parser, JSON Parser)
- **Document → Binary**: Use formatter snaps (CSV Formatter, JSON Formatter)
- **Binary → Binary**: File operations, transformations

### Multi-View Snaps
Some snaps require multiple input/output views:
- **Copy Snap**: Minimum 2 output views (output0, output1)
- **Union Snap**: Minimum 2 input views
- **Join Snap**: 2 input views (left, right)
- **Router Snap**: Multiple outputs based on conditions

## Expression Validation

### String Literal Rules
- **Always Quote**: String literals must be wrapped in double quotes
- **Escape Sequences**: Use proper escaping for special characters
- **Concatenation**: Quote each string segment separately

#### Correct Expression Examples
```json
"value": "\"SELECT * FROM Table WHERE id = \" + $id"
"value": "$field != null && $field.length() > 0 ? $field.substring(0, 10) : \"default\""
"value": "\"Error: \" + $error_message + \" at \" + Date.now().toString()"
```

#### Common Expression Errors
```json
// ❌ Incorrect - unquoted string
"value": "SELECT * FROM Table WHERE id = " + $id

// ❌ Incorrect - missing quotes in ternary
"value": "$field ? $field : default"

// ❌ Incorrect - wrong date format
"value": Date.now().toISOString()
```

## Render Map Validation

### Grid Positioning
- **Sequential Layout**: Use incremental x positions (2, 3, 4, ...)
- **Branching**: Use different y positions for parallel paths
- **Spacing**: Minimum 1 grid unit between connected snaps

### Multi-Output Snap Rendering
Copy snaps and other multi-output snaps require render_map output positioning:
```json
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
```

## Performance Considerations

### Validation Order
1. **JSON Syntax** (fastest, fails early)
2. **Required Fields** (quick grep operations)
3. **Structure Validation** (snap/link consistency)
4. **UUID Validation** (more complex but thorough)

### Git Hook Optimization
- **Changed Files Only**: Only validate modified .slp files
- **Early Exit**: Stop on first error for fast feedback
- **Silent Success**: No output when validation passes
- **AWK Processing**: Single-pass file analysis for speed

## Error Categories

### Critical Errors (Block Commit)
- JSON syntax errors
- Missing required fields
- Snap/link count mismatches
- Invalid UUID references
- Missing snap configurations

### Warnings (Allow with Notice)
- Unusual snap configurations
- Performance concerns
- Style guideline violations
- Deprecated snap versions

## Validation Tools

### Git Pre-Commit Hook
- **Fast validation** (<100ms target)
- **Automatic enforcement**
- **Helpful error messages**
- **Emergency override**: `git commit --no-verify`

### Comprehensive Validation Script
- **Detailed analysis** with verbose output
- **JSON output format** for automation
- **Performance profiling**
- **Best practice recommendations**

### Manual Validation Commands
```bash
# Quick JSON check
python3 -m json.tool pipeline.slp

# AWK structure validation
awk -f validate_structure.awk pipeline.slp

# Comprehensive validation
./validate-slp.sh -v pipeline.slp

# JSON output for automation
./validate-slp.sh -j pipeline.slp | jq .
```