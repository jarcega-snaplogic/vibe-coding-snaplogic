# SnapLogic Pipeline Patterns Guide

Comprehensive guide to common SnapLogic pipeline patterns, architectural decisions, and implementation best practices. This guide helps developers choose the right pattern for their use case and implement it correctly.

## 🎯 Pattern Selection Guide

| Use Case | Recommended Pattern | Complexity | Performance |
|----------|-------------------|------------|-------------|
| **Pipeline Chaining** | 2-Snap (Execute → Mapper) | Low | High |
| **File Processing** | 3-Snap (Reader → Parser → Mapper) | Medium | High |
| **Batch Processing** | Group By N → Processing | Medium | Medium |
| **Multi-Output** | Copy → Multiple Paths | High | Medium |
| **Data Merging** | Multiple → Union → Processing | High | Medium |
| **Conditional Logic** | Router → Conditional Paths | High | High |

## 🔗 Two-Snap Patterns

### Pipeline Execute → Mapper
**When to Use**:
- Chaining existing pipelines with data transformation
- Phase-based development approach
- Reusing validated pipeline logic

**Architecture Benefits**:
- **Modularity**: Separate concerns across pipelines
- **Reusability**: Execute existing pipelines multiple times
- **Testability**: Test each phase independently
- **Maintainability**: Update transformations without touching source logic

**Implementation Example**:
```json
{
    "pattern": "Pipeline Execute → Mapper",
    "snaps": [
        {
            "type": "com-snaplogic-snaps-flow-pipeexec",
            "purpose": "Execute source pipeline",
            "config": {
                "pipeline": "SourcePipelineName",
                "poolSize": 1,
                "reuse": false
            }
        },
        {
            "type": "com-snaplogic-snaps-transform-datatransform", 
            "purpose": "Transform pipeline output",
            "config": {
                "nullSafeAccess": true,
                "passThrough": false
            }
        }
    ]
}
```

**Best Practices**:
- Use descriptive pipeline names in execute snap
- Set appropriate timeout values for long-running pipelines
- Enable nullSafeAccess in mapper for robust field handling
- End with mapper output (no JSON Formatter/File Writer for chaining)

### Pipeline Execute → Group By N
**When to Use**:
- Collecting individual pipeline outputs for batch processing
- Aggregating streaming data from another pipeline
- Preparing data for AI/LLM analysis

**Key Configuration**:
```json
{
    "groupBy": {
        "groupSize": 0,           // Collect all documents
        "targetField": "records", // Array field name
        "minGroupSize": 1        // Minimum for processing
    }
}
```

## 📄 Three-Snap Patterns

### File Reader → CSV Parser → Mapper
**When to Use**:
- Processing CSV files from SLDB or file system
- ETL workflows with file-based sources
- Structured data ingestion

**Data Flow**:
```
File (Binary) → CSV Parser (Binary → Document) → Mapper (Document → Document)
```

**Configuration Guidelines**:

#### File Reader
```json
{
    "filePath": "data.csv",              // SLDB file
    "enableStaging": false,              // Direct read
    "executeDuringPreview": true         // Allow preview
}
```

#### CSV Parser
```json
{
    "containsHeader": true,              // Use first row as headers
    "delimiter": ",",                    // Standard CSV comma
    "charset": "Auto BOM detect",        // Handle encoding
    "ignoreEmptyData": true             // Skip empty rows
}
```

#### Mapper
```json
{
    "transformations": {
        "mappingTable": [
            {
                "expression": "$['CSV Column Name']",
                "targetPath": "clean_field_name"
            }
        ]
    }
}
```

### File Reader → JSON Parser → Mapper
**When to Use**:
- Processing JSON files or JSON Lines format
- API response files stored as JSON
- Configuration file processing

**Key Differences from CSV**:
- JSON Parser instead of CSV Parser
- No header handling needed
- Direct field access without bracket notation

## 📊 Batch Processing Patterns

### Pipeline Execute → Group By N → AI Processing
**When to Use**:
- AI analysis requiring all documents together
- Aggregate calculations across records
- Batch API calls for efficiency

**Architecture Flow**:
```
Source Pipeline → Collect All → Process Batch → Individual Results
```

**Configuration Strategy**:
```json
{
    "groupByN": {
        "groupSize": 0,                  // All documents
        "flushTimeoutSecs": 0,          // No timeout
        "memorySensitivity": "None",     // Use memory as needed
        "targetField": "batch_data"      // Descriptive field name
    }
}
```

**Memory Considerations**:
- Monitor memory usage with large datasets
- Consider breaking into smaller batches for very large data
- Use `memorySensitivity` settings appropriately

### Group By N → Copy → Multiple Processing
**When to Use**:
- Processing same data through multiple algorithms
- A/B testing different processing approaches
- Parallel analysis workflows

**Implementation Pattern**:
```
Group By N → Copy → [Path A: AI Analysis]
                 → [Path B: Statistical Analysis]  
                 → [Path C: Reporting]
```

## 🔀 Multi-Path Patterns

### Copy Snap Patterns
**When to Use**:
- Split data for parallel processing
- Multiple output destinations
- A/B testing scenarios

**Critical Configuration**:
```json
{
    "render_map": {
        "detail_map": {
            "copy_snap_id": {
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

**Common Pitfall**: Missing render_map output configuration causes only output0 to appear in SnapLogic Designer.

### Router Patterns
**When to Use**:
- Conditional data routing
- Business rule-based processing
- Error handling and data validation

**Configuration Strategy**:
```json
{
    "routes": [
        {
            "condition": "$status == 'active'",
            "output": "active_path"
        },
        {
            "condition": "$status == 'inactive'", 
            "output": "inactive_path"
        }
    ]
}
```

## 🔄 Data Merging Patterns

### Union Patterns
**When to Use**:
- Combining data from multiple sources
- Merging parallel processing results
- Consolidating filtered datasets

**Minimum Requirements**:
- 2 input views minimum
- Compatible document structures
- Proper error handling for mismatched data

### Join Patterns
**When to Use**:
- Relational data operations
- Enriching data with lookup information
- Combining related datasets

**Join Types**:
- **Inner Join**: Only matching records
- **Left Join**: All left records + matching right
- **Right Join**: All right records + matching left
- **Full Outer Join**: All records from both sides

## 🏗️ Architectural Decisions

### When to Chain vs. Combine
**Chain Pipelines When**:
- Logic is complex and benefits from separation
- Different teams maintain different parts
- Reusability across multiple use cases
- Testing isolation is important

**Combine in Single Pipeline When**:
- Simple, linear data flow
- Performance is critical (avoid pipeline overhead)
- Tight coupling between processing steps
- Small, focused functionality

### Performance Considerations

#### Pipeline Execute Overhead
- Each Pipeline Execute adds ~50-100ms overhead
- Connection setup and teardown costs
- Consider for high-frequency operations

#### Memory Usage Patterns
- **Group By N**: Accumulates all documents in memory
- **Copy**: Duplicates data across outputs
- **Large Files**: Consider streaming vs. batch processing

#### Optimization Strategies
- Use passThrough sparingly in mappers
- Minimize field copying with targeted transformations
- Consider data volume when choosing patterns

## 🎨 Visual Layout Guidelines

### Grid Positioning
- **Linear Flow**: Horizontal progression (x: 2, 3, 4, ...)
- **Branching**: Vertical spacing for parallel paths
- **Convergence**: Bring parallel paths back together
- **Spacing**: Minimum 1 grid unit between connected snaps

### Designer-Friendly Practices
- Use descriptive snap labels
- Include meaningful notes and documentation
- Organize related snaps visually
- Use consistent UUID patterns

## 🔍 Pattern Validation

### Structural Validation
- Snap count matches link count (n snaps = n-1 links)
- All UUIDs are unique and properly referenced
- View types are compatible across connections
- Required properties are present for each snap type

### Functional Validation
- Data flow makes logical sense
- Error handling is appropriate
- Performance characteristics meet requirements
- Security and access controls are proper

### Best Practice Validation
- Follows established naming conventions
- Uses standard configuration patterns
- Includes proper documentation
- Handles edge cases appropriately

## 📋 Pattern Checklist

### Before Implementation
- [ ] Use case clearly defined
- [ ] Pattern selected based on requirements
- [ ] Data volume and performance considered
- [ ] Error handling strategy planned

### During Implementation
- [ ] Follow UUID increment pattern
- [ ] Include all required snap properties
- [ ] Set up proper view type compatibility
- [ ] Add descriptive labels and notes

### After Implementation
- [ ] Validate with validation tools
- [ ] Test with representative data
- [ ] Document specific configuration choices
- [ ] Verify performance meets requirements

### Before Deployment
- [ ] End-to-end testing complete
- [ ] Error scenarios tested
- [ ] Documentation updated
- [ ] Team review completed

---

*Choose the right pattern, implement it correctly, validate thoroughly.*