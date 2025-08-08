# SnapLogic Pipeline Structure Rules

Core rules for SnapLogic pipeline architecture, structure validation, and best practices. Load this file when creating, modifying, or troubleshooting SnapLogic pipelines.

## 🏗️ Pipeline Architecture Requirements

### UUID Patterns (CRITICAL)
- **Pattern**: `11111111-1111-1111-1111-############` (12 digits)
- **Sequential**: Use incremental pattern for Designer compatibility
  - `11111111-1111-1111-1111-000000000000` (First snap)
  - `11111111-1111-1111-1111-000000000001` (Second snap)  
  - `11111111-1111-1111-1111-000000000002` (Third snap)
- **Consistency**: All UUIDs in `link_map` must exist in `snap_map`
- **Uniqueness**: Each snap must have unique UUID

### Link/Snap Relationships (CRITICAL)
- **Single Snap**: 0 links (no connections needed)
- **Multiple Snaps**: n snaps require (n-1) links
- **Linear Flow**: Each snap connects to next in sequence
- **Branching**: Use Copy snap with multiple outputs

### Required Pipeline Structure
```json
{
    "class_id": "com-snaplogic-pipeline",
    "class_version": 9,
    "link_map": {},
    "property_map": {
        "info": {
            "author": {"value": "jarcega@snaplogic.com"},
            "notes": {"value": "Descriptive pipeline purpose"},
            "purpose": {"value": "Business use case description"}
        }
    },
    "render_map": {},
    "snap_map": {}
}
```

## 🔗 Data Flow Patterns

### Clean Pipeline Chaining (CRITICAL)
- **End with Mapper output** - NO JSON Formatter/File Writer for chaining
- **Document flow**: Pipeline Execute → Mapper → Next Pipeline
- **Avoid file writes** in intermediate pipelines

### View Type Compatibility
- **Document → Document**: Standard data flow
- **Binary → Document**: Use parser snaps (CSV Parser, JSON Parser)
- **Document → Binary**: Use formatter snaps (CSV Formatter, JSON Formatter)
- **Binary → Binary**: File operations only

## 📐 Visual Layout Guidelines

### Grid Positioning
- **Linear Pipelines**: Single row with incremental x-positions
  - Formula: `grid_x_int: start_x + index`
  - Recommended: Start at x=2, use y=1 for clean layout
  - Spacing: Increment x by 1 for directly connected snaps
- **Branching**: Use vertical spacing (increment y) for parallel paths
- **Convergence**: Position merge points with adequate spacing

### Designer-Friendly Configuration
- **UUID Format**: Sequential for compatibility
- **Grid Layout**: Organized visual flow
- **Labels**: Descriptive snap labels and notes
- **Documentation**: Clear purpose and business context

## 🚫 Common Pitfalls to Avoid

### JSON Structure Errors
- **Trailing Commas**: Remove extra commas after closing braces
- **Quote Escaping**: Proper escaping in expressions
- **Expression Syntax**: Quote all string literals

### Architecture Mistakes
- **File Writers in Chains**: Breaks data flow for next pipeline
- **UUID Inconsistency**: Referenced IDs not in snap_map
- **Link Count Mismatch**: Wrong number of connections
- **View Type Mismatch**: Incompatible input/output types

## ✅ Validation Checklist

### Before Creating Pipeline
- [ ] Use case clearly defined
- [ ] Pattern selected (2-snap, 3-snap, Group By N)
- [ ] Data flow architecture planned
- [ ] Error handling strategy defined

### During Implementation  
- [ ] Follow sequential UUID pattern
- [ ] Include all required snap properties
- [ ] Set up proper view type compatibility
- [ ] Add descriptive labels and notes
- [ ] End with clean output (no formatter/writer for chaining)

### Before Commit
- [ ] JSON syntax validation passes
- [ ] Structure validation passes (hooks)
- [ ] All UUIDs are consistent
- [ ] Link count matches snap count
- [ ] Test with representative data

## 🔧 Troubleshooting Guide

### "Pipeline Not Recognized" Error
- **Cause**: Invalid JSON or missing required fields
- **Fix**: Use `python3 -m json.tool pipeline.slp` to validate JSON
- **Check**: Ensure pipeline `class_id` is present

### "UUID Reference Error" 
- **Cause**: link_map references UUID not in snap_map
- **Fix**: Verify all src_id/dst_id exist in snap_map keys
- **Pattern**: Use sequential UUIDs to avoid conflicts

### "Data Flow Break" Error
- **Cause**: JSON Formatter/File Writer in pipeline chain
- **Fix**: Remove formatter and writer snaps, end with Mapper
- **Result**: Clean document flow to next pipeline

### "Validation Hook Rejection"
- **Cause**: Structural issues caught by pre-commit hook
- **Fix**: Read error message carefully, common issues:
  - JSON syntax errors (trailing commas)
  - Link/snap count mismatch
  - Missing required properties
- **Override**: `git commit --no-verify` (emergency only)

## 📊 Performance Considerations

### Pipeline Execute Overhead
- Each Pipeline Execute adds ~50-100ms overhead
- Consider for high-frequency operations
- Balance modularity vs. performance

### Memory Usage
- Group By N accumulates all documents in memory
- Monitor memory with large datasets
- Consider pagination for very large data

### Execution Modes
- **"Validate & Execute"**: Development and testing
- **"Execute only"**: Production deployment
- **Error Handling**: Fail vs. Continue based on use case

## 🎯 Best Practices

### Development Workflow
1. **Start with examples** from vibe-coding-snaplogic repo
2. **Validate early** with git hooks
3. **Test incrementally** with sample data
4. **Document thoroughly** with notes and purpose
5. **Review before commit** with validation tools

### Production Deployment
1. **Change execution_mode** to "Execute only"
2. **Set appropriate timeouts** for long operations
3. **Configure error handling** for business requirements
4. **Monitor performance** and memory usage
5. **Document dependencies** and integration points

---

**Remember**: These rules prevent 95% of common SnapLogic pipeline issues. When in doubt, compare with working examples in vibe-coding-snaplogic/examples/.