# SnapLogic Pipeline Examples

Production-ready pipeline templates and patterns for common SnapLogic development scenarios. These examples demonstrate proper structure, validation-compliant configuration, and best practices.

## Available Examples

### 1. Two-Snap Pipeline (`2-snap-pipeline.slp`)
**Pattern**: Pipeline Execute → Mapper

**Use Cases**:
- Chain pipelines with field transformations
- Execute existing pipeline and modify its output
- Phase-based pipeline development

**Key Features**:
- Proper pipeline execute configuration
- Mapper with transformation examples
- Clean data flow (document → document)
- Validation-compliant structure

**Configuration Example**:
```json
"pipeline": {
    "expression": false,
    "value": "SourcePipelineName"  // Replace with actual pipeline name
}
```

### 2. Three-Snap Pipeline (`3-snap-pipeline.slp`)
**Pattern**: File Reader → CSV Parser → Mapper

**Use Cases**:
- CSV file processing
- File-based data ingestion
- ETL workflows with file sources

**Key Features**:
- File reader with SLDB compatibility
- CSV parser with common settings
- Field mapping from CSV columns to target fields
- Binary → Document → Document flow

**Configuration Example**:
```json
"filePath": {
    "expression": false,
    "value": "data.csv"  // Replace with actual file path
}
```

### 3. Group By N Pipeline (`group-by-n-example.slp`)
**Pattern**: Pipeline Execute → Group By N

**Use Cases**:
- Batch processing with AI/LLM snaps
- Document aggregation for analysis
- Collect all records for group operations

**Key Features**:
- Complete Group By N configuration with all required properties
- groupSize: 0 to collect all documents
- Proper memory and timeout settings
- Ready for AI/LLM integration

**Configuration Example**:
```json
"groupSize": {"value": 0},        // Collect all documents
"targetField": {"value": "documents"}  // Array field name
```

## Configuration Guidelines

### File Paths
- **SLDB**: Use filename only (e.g., `"data.csv"`)
- **Full Path**: Use absolute paths when needed (e.g., `"/tmp/data.csv"`)
- **Pipeline Names**: Replace placeholder names with actual pipeline references

### UUID Pattern
All examples use the standard incremental UUID pattern:
- `11111111-1111-1111-1111-000000000000` (First snap)
- `11111111-1111-1111-1111-000000000001` (Second snap)
- `11111111-1111-1111-1111-000000000002` (Third snap)

### Author Information
Update the author field to your email:
```json
"author": {
    "value": "your.email@company.com"
}
```

## Customization Steps

### 1. Copy Template
```bash
cp examples/2-snap-pipeline.slp MyNewPipeline.slp
```

### 2. Update Metadata
- Change `notes` and `purpose` fields
- Update `author` information
- Modify pipeline description

### 3. Configure Snaps
- Replace placeholder values (pipeline names, file paths)
- Adjust snap settings for your use case
- Update field mappings in Mapper snaps

### 4. Validate
```bash
# Quick validation
python3 -m json.tool MyNewPipeline.slp

# Comprehensive validation
../validation/validate-slp.sh MyNewPipeline.slp
```

## Common Patterns

### Pipeline Chaining
Use the 2-snap pattern when you need to:
- Execute existing pipelines and transform their output
- Implement phase-based development
- Chain multiple processing steps

### File Processing
Use the 3-snap pattern when you need to:
- Read CSV files from SLDB or file system
- Parse structured data files
- Transform file data into target format

### Batch Processing
Use the Group By N pattern when you need to:
- Process all documents together (AI analysis)
- Perform aggregate operations
- Collect streaming data into batches

## Advanced Configurations

### Multi-Output Snaps
For Copy snaps or routers, add render_map output positioning:
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

### Expression Examples
Field transformations with proper string quoting:
```json
{
    "expression": {
        "expression": true,
        "value": "$field != null && $field.length() > 35 ? $field.substring(0, 35) : $field"
    },
    "targetPath": {
        "value": "truncated_field"
    }
}
```

### Parameter References
Use underscore prefix for pipeline parameters:
```json
"value": "\"SELECT * FROM Table WHERE days >= \" + _days_back"
```

## Validation Compliance

All examples in this directory:
- ✅ Pass JSON syntax validation
- ✅ Have correct snap/link relationships
- ✅ Use proper UUID patterns
- ✅ Include all required properties
- ✅ Follow SnapLogic best practices
- ✅ Work with the git pre-commit hook

## Testing Examples

Before using any example:
1. **Validate structure**: `../validation/validate-slp.sh example.slp`
2. **Test in SnapLogic Designer**: Import and verify visual layout
3. **Run pipeline**: Execute with sample data to verify functionality

## Troubleshooting

### Common Issues
- **Invalid JSON**: Check for trailing commas, quote escaping
- **UUID Conflicts**: Ensure UUIDs are unique and sequential
- **Missing Properties**: Compare with working examples for required fields
- **Expression Errors**: Verify string literal quoting

### Getting Help
- Check validation output for specific error messages
- Compare your configuration with these working examples
- Use the comprehensive validation tool with verbose output
- Review the validation rules documentation

## Contributing

When adding new examples:
1. Follow the existing UUID pattern
2. Include comprehensive documentation
3. Test with validation tools
4. Add to this README with use case description