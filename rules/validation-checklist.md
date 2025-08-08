# SnapLogic Pipeline Validation Checklist

Systematic validation procedures, troubleshooting steps, and quality assurance processes. Load this file when debugging validation issues or ensuring pipeline quality.

## 🔍 Pre-Commit Validation Process

### Automatic Validation (Git Hooks)
The git pre-commit hook automatically validates:
1. **JSON Syntax** - Proper structure, no trailing commas
2. **Pipeline Structure** - Required fields, proper class_id
3. **Snap/Link Consistency** - Correct relationship counts
4. **UUID References** - All linked IDs exist in snap_map

### Manual Validation Commands
```bash
# Quick JSON validation
python3 -m json.tool pipeline.slp

# Comprehensive validation
./vibe-coding-snaplogic/validation/validate-slp.sh pipeline.slp

# Verbose analysis
./vibe-coding-snaplogic/validation/validate-slp.sh -v pipeline.slp

# JSON output (automation)
./vibe-coding-snaplogic/validation/validate-slp.sh -j pipeline.slp | jq .
```

## ✅ Development Validation Checklist

### Phase 1: Design Validation
- [ ] **Use Case Defined** - Clear business purpose documented
- [ ] **Pattern Selected** - 2-snap, 3-snap, or Group By N chosen
- [ ] **Data Flow Mapped** - Input → Processing → Output defined
- [ ] **Error Handling Planned** - Failure scenarios considered
- [ ] **Performance Requirements** - Volume and speed requirements known

### Phase 2: Implementation Validation
- [ ] **UUID Pattern** - Sequential incremental pattern used
- [ ] **Required Properties** - All mandatory snap properties included
- [ ] **View Compatibility** - Input/output types match across snaps
- [ ] **Expression Syntax** - String literals properly quoted
- [ ] **Labels & Documentation** - Descriptive names and notes added

### Phase 3: Structure Validation
- [ ] **JSON Syntax** - Valid JSON structure confirmed
- [ ] **Link Count** - (n snaps = n-1 links) relationship correct
- [ ] **UUID Consistency** - All link references exist in snap_map
- [ ] **Required Fields** - Pipeline class_id and mandatory properties present
- [ ] **Render Map** - Multi-output snaps have proper positioning

### Phase 4: Functional Validation
- [ ] **Data Flow Logic** - Processing logic makes business sense
- [ ] **Field Mappings** - Source to target mappings are correct
- [ ] **Business Rules** - Domain-specific validations implemented
- [ ] **Edge Cases** - Null values, empty data, error conditions handled
- [ ] **Performance** - Acceptable execution time for expected volume

### Phase 5: Integration Validation
- [ ] **Pipeline Chaining** - Clean output for downstream pipelines
- [ ] **File Operations** - Proper binary/document conversion
- [ ] **Account Configuration** - Authentication and permissions set
- [ ] **Environment Variables** - Parameters and settings configured
- [ ] **Dependencies** - Required external resources available

## 🚨 Common Validation Errors & Fixes

### JSON Syntax Errors

#### Trailing Comma Error
```bash
# Error: Expecting property name enclosed in double quotes
python3 -m json.tool pipeline.slp
```
**Fix**: Remove extra comma after closing brace
```json
// ❌ Wrong
        }
    },
}

// ✅ Correct  
        }
    }
}
```

#### String Escaping Error
```bash
# Error in expressions with quotes
```
**Fix**: Proper quote escaping in expressions
```json
// ❌ Wrong
"value": "SELECT * FROM Table WHERE name = "test""

// ✅ Correct
"value": "\"SELECT * FROM Table WHERE name = \\\"test\\\"\""
```

### Structure Validation Errors

#### Link/Snap Count Mismatch
```bash
# Hook Error: Link/snap count mismatch: 3 snaps should have 2 links, found 1
```
**Fix**: Add missing link or remove extra snap
- Check link_map has (n-1) links for n snaps
- Verify all snaps are connected in proper sequence

#### UUID Reference Error  
```bash
# Hook Error: UUID referenced in link_map but not found in snap_map
```
**Fix**: Ensure UUID consistency
- All src_id/dst_id in link_map exist as keys in snap_map
- Use sequential UUID pattern to avoid conflicts
- Copy UUIDs exactly (no typos)

#### Missing Pipeline Class
```bash
# Error: Missing pipeline class_id: com-snaplogic-pipeline
```
**Fix**: Add required pipeline structure
```json
{
    "class_id": "com-snaplogic-pipeline",
    "class_version": 9,
    // ... rest of pipeline
}
```

### Snap Configuration Errors

#### Missing Required Properties
```bash
# Error: Property 'nullSafeAccess' required for Mapper snap
```
**Fix**: Add all mandatory properties for snap type
- Reference working examples in vibe-coding-snaplogic/examples/
- Use snap schema documentation
- Include all settings properties

#### View Type Mismatch
```bash
# Error: Cannot connect document output to binary input
```
**Fix**: Add appropriate conversion snap
- Document → Binary: Use Document to Binary converter
- Binary → Document: Use appropriate parser (CSV, JSON)
- Check snap documentation for input/output requirements

#### Expression Syntax Error
```bash
# Error: Invalid expression syntax
```
**Fix**: Quote all string literals
```json
// ❌ Wrong
"value": "SELECT * FROM " + $table + " WHERE id = " + $id

// ✅ Correct  
"value": "\"SELECT * FROM \" + $table + \" WHERE id = \" + $id"
```

## 🔧 Systematic Troubleshooting Process

### Step 1: Identify Error Category
1. **JSON Syntax** - Run `python3 -m json.tool pipeline.slp`
2. **Structure Issues** - Run git hook manually
3. **Snap Configuration** - Compare with working examples
4. **Logic Errors** - Review business requirements

### Step 2: Isolate Root Cause
1. **Start Simple** - Test with minimal pipeline first
2. **Add Incrementally** - Add one snap at a time
3. **Compare Working** - Use vibe-coding-snaplogic examples
4. **Check Documentation** - Reference snap schema rules

### Step 3: Apply Systematic Fixes
1. **Fix Syntax First** - JSON must be valid before other checks
2. **Validate Structure** - Ensure proper pipeline architecture
3. **Configure Snaps** - Add all required properties
4. **Test Incrementally** - Validate after each change

### Step 4: Verify Solution
1. **Run Full Validation** - All validation tools pass
2. **Test with Data** - Execute with representative sample
3. **Check Performance** - Meets speed/memory requirements
4. **Document Changes** - Update notes with lessons learned

## 📊 Validation Tools & Scripts

### Git Pre-Commit Hook
- **Location**: `.git/hooks/pre-commit`
- **Speed**: <100ms for typical pipelines
- **Coverage**: JSON, structure, UUID consistency
- **Override**: `git commit --no-verify` (emergency only)

### Comprehensive Validation Script
- **Location**: `vibe-coding-snaplogic/validation/validate-slp.sh`
- **Features**: Verbose output, JSON format, detailed analysis
- **Usage**: Development debugging and detailed analysis

### AWK Structure Validator  
- **Location**: `vibe-coding-snaplogic/validation/validate_structure.awk`
- **Speed**: Single-pass file analysis
- **Purpose**: Fast structure validation for git hooks

### Installation & Updates
```bash
# Install hooks in new repository
./vibe-coding-snaplogic/validation/install-hooks.sh

# Update existing hooks (when rules change)
./vibe-coding-snaplogic/validation/install-hooks.sh

# Test hook installation
.git/hooks/pre-commit
```

## 🎯 Quality Assurance Standards

### Minimum Acceptance Criteria
- [ ] **JSON Valid** - Passes `python3 -m json.tool`
- [ ] **Structure Valid** - Passes git hook validation
- [ ] **Examples Match** - Follows patterns from working examples
- [ ] **Documentation Complete** - Purpose, notes, and labels added
- [ ] **Error Handling** - Appropriate failure behavior configured

### Production Readiness Criteria  
- [ ] **Performance Tested** - Acceptable execution time
- [ ] **Error Scenarios** - Edge cases and failures handled
- [ ] **Security Review** - No exposed credentials or sensitive data
- [ ] **Integration Tested** - Works with dependent systems
- [ ] **Monitoring Ready** - Appropriate logging and alerting

### Code Review Checklist
- [ ] **Business Logic** - Processing rules implement requirements correctly
- [ ] **Architecture** - Pattern choice appropriate for use case
- [ ] **Maintainability** - Code is readable and well-documented
- [ ] **Reusability** - Components can be reused where appropriate
- [ ] **Standards Compliance** - Follows organizational guidelines

## 🚀 Continuous Improvement

### Learning from Validation Failures
1. **Document Patterns** - Add new error patterns to this guide
2. **Update Examples** - Create examples for new use cases
3. **Improve Tools** - Enhance validation scripts based on common issues
4. **Share Knowledge** - Update team documentation with lessons learned

### Validation Tool Evolution
1. **Performance Optimization** - Keep validation fast (<100ms)
2. **Coverage Expansion** - Add new validation rules as needed
3. **User Experience** - Improve error messages and remediation guidance
4. **Integration Enhancement** - Better tooling integration and automation

---

**Remember**: Validation is about preventing problems, not just catching them. Use this checklist proactively during development, not just when things break.