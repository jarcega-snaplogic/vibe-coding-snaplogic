# Field Transformation Rules & Patterns

Business logic implementations, field mapping patterns, and data transformation best practices for SnapLogic Mapper snaps and related transformations.

## 🎯 Mapper Configuration Fundamentals

### Core Mapper Settings (ALWAYS Required)
```json
{
    "class_id": "com-snaplogic-snaps-transform-datatransform",
    "class_version": 4,
    "settings": {
        "execution_mode": {"value": "Validate & Execute"},
        "nullSafeAccess": {"value": true},           // CRITICAL: Always true
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

### Mapping Table Structure
```json
{
    "expression": {
        "expression": true,
        "value": "TRANSFORMATION_EXPRESSION"
    },
    "targetPath": {
        "value": "target_field_name"
    }
}
```

## 🔧 Common Transformation Patterns

### Simple Field Mapping
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

### CSV Column Mapping (Bracket Notation)
```json
{
    "expression": {
        "expression": true,
        "value": "$['CSV Column Name']"
    },
    "targetPath": {
        "value": "clean_field_name"
    }
}
```

### Default Value Assignment
```json
{
    "expression": {
        "expression": true,
        "value": "$field == null || $field == \"\" ? \"default_value\" : $field"
    },
    "targetPath": {
        "value": "field_with_default"
    }
}
```

### Static Value Assignment
```json
{
    "expression": {
        "expression": true,
        "value": "\"static_value\""
    },
    "targetPath": {
        "value": "constant_field"
    }
}
```

## ✂️ String Processing Patterns

### String Truncation (Character Limit)
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

### String Overflow Handling
```json
{
    "expression": {
        "expression": true,
        "value": "$field != null && $field.length() > 35 ? $field.substring(35, Math.min(70, $field.length())) : null"
    },
    "targetPath": {
        "value": "overflow_field"
    }
}
```

### String Cleaning & Normalization
```json
{
    "expression": {
        "expression": true,
        "value": "$field != null ? $field.trim().toUpperCase() : null"
    },
    "targetPath": {
        "value": "normalized_field"
    }
}
```

## 🔢 Numeric & Date Transformations

### Number Formatting
```json
{
    "expression": {
        "expression": true,
        "value": "$amount != null ? parseFloat($amount).toFixed(2) : \"0.00\""
    },
    "targetPath": {
        "value": "formatted_amount"
    }
}
```

### Date Formatting
```json
{
    "expression": {
        "expression": true,
        "value": "$date_field != null ? Date.parse($date_field).toLocaleDateString() : null"
    },
    "targetPath": {
        "value": "formatted_date"
    }
}
```

## 🏢 Business Logic Patterns

### Conditional Business Rules
```json
{
    "expression": {
        "expression": true,
        "value": "$status == \"active\" && $amount > 1000 ? \"priority\" : \"standard\""
    },
    "targetPath": {
        "value": "priority_level"
    }
}
```

### Multi-Condition Logic
```json
{
    "expression": {
        "expression": true,
        "value": "$region == \"EMEA\" ? ($amount > 500 ? \"high_value\" : \"standard\") : \"other_region\""
    },
    "targetPath": {
        "value": "customer_segment"
    }
}
```

### Validation & Quality Checks
```json
{
    "expression": {
        "expression": true,
        "value": "$email != null && $email.contains(\"@\") ? $email : \"invalid_email\""
    },
    "targetPath": {
        "value": "validated_email"
    }
}
```

## 🎪 Real-World Examples (Shippeo Integration)

### Address Truncation with Overflow
```json
{
    "expression": {
        "expression": true,
        "value": "$pickup_name != null && $pickup_name.length() > 35 ? $pickup_name.substring(0, 35) : $pickup_name"
    },
    "targetPath": {
        "value": "pickup_name"
    }
},
{
    "expression": {
        "expression": true,
        "value": "$pickup_address1 != null && $pickup_address1.length() > 35 ? $pickup_address1.substring(35, Math.min(70, $pickup_address1.length())) : null"
    },
    "targetPath": {
        "value": "pickup_address2"
    }
}
```

### Goods Description with Default
```json
{
    "expression": {
        "expression": true,
        "value": "$goodsDescription == null || $goodsDescription == \"\" ? \"general goods\" : $goodsDescription"
    },
    "targetPath": {
        "value": "goodsDescription"
    }
}
```

### Transport Mode with Default
```json
{
    "expression": {
        "expression": true,
        "value": "$shipment_transportMode == null || $shipment_transportMode == \"\" ? \"road\" : $shipment_transportMode"
    },
    "targetPath": {
        "value": "shipment_transportMode"
    }
}
```

### Qualifier Fields (Static Values)
```json
{
    "expression": {
        "expression": true,
        "value": "\"ZZ\""
    },
    "targetPath": {
        "value": "pickup_qualifier"
    }
},
{
    "expression": {
        "expression": true,
        "value": "\"ZZ\""
    },
    "targetPath": {
        "value": "consignee_qualifier"
    }
}
```

## 🔗 Complex Data Structures

### Object Construction
```json
{
    "expression": {
        "expression": true,
        "value": "{\n  \"id\": $id,\n  \"name\": $name,\n  \"status\": \"active\"\n}"
    },
    "targetPath": {
        "value": "customer_object"
    }
}
```

### Array Processing
```json
{
    "expression": {
        "expression": true,
        "value": "$items.map(item => {\n  item.processed = true;\n  return item;\n})"
    },
    "targetPath": {
        "value": "processed_items"
    }
}
```

### Nested Field Access
```json
{
    "expression": {
        "expression": true,
        "value": "$customer.address.street != null ? $customer.address.street : \"Unknown\""
    },
    "targetPath": {
        "value": "street_address"
    }
}
```

## 📊 Data Aggregation Patterns

### Grouped Data Processing
```json
{
    "expression": {
        "expression": true,
        "value": "$orders.length()"
    },
    "targetPath": {
        "value": "order_count"
    }
}
```

### Summary Calculations
```json
{
    "expression": {
        "expression": true,
        "value": "$orders.reduce((sum, order) => sum + order.amount, 0)"
    },
    "targetPath": {
        "value": "total_amount"
    }
}
```

## ⚠️ Expression Syntax Rules (CRITICAL)

### String Literal Quoting
**ALWAYS wrap string literals in double quotes**
```json
// ✅ Correct
"value": "\"String literal \" + $variable + \" more text\""

// ❌ Wrong - causes pipeline recognition failure  
"value": "String literal " + $variable + " more text"
```

### Parameter References
```json
// Pipeline parameters (use underscore)
"value": "\"Days back: \" + _days_parameter"

// Document fields (use dollar)
"value": "\"Customer: \" + $customer_name"

// Grouped data (use mustache in prompts)
"value": "{{$grouped_data}}"
```

### Common Expression Errors
```json
// ❌ Wrong - JavaScript methods
"value": "Date.now().toISOString().substring(0,10)"

// ✅ Correct - SnapLogic methods
"value": "Date.now().toLocaleDateString().replace(/\\//g,'')"

// ❌ Wrong - unescaped regex
"value": "$text.replace(/\//g,'')"  

// ✅ Correct - properly escaped
"value": "$text.replace(/\\//g,'')"
```

## 🎨 Formatting & Display Patterns

### User-Friendly Labels
```json
{
    "expression": {
        "expression": true,
        "value": "$status == \"A\" ? \"Active\" : ($status == \"I\" ? \"Inactive\" : \"Unknown\")"
    },
    "targetPath": {
        "value": "status_label"
    }
}
```

### Concatenated Display Fields
```json
{
    "expression": {
        "expression": true,
        "value": "$first_name + \" \" + $last_name"
    },
    "targetPath": {
        "value": "full_name"
    }
}
```

### Formatted Identifiers
```json
{
    "expression": {
        "expression": true,
        "value": "\"ORD-\" + $order_id.toString().padStart(6, \"0\")"
    },
    "targetPath": {
        "value": "formatted_order_id"
    }
}
```

## 🔍 Testing & Validation Patterns

### Field Validation Expressions
```json
{
    "expression": {
        "expression": true,
        "value": "$phone != null && $phone.length() >= 10 ? $phone : \"INVALID_PHONE\""
    },
    "targetPath": {
        "value": "validated_phone"
    }
}
```

### Data Quality Flags
```json
{
    "expression": {
        "expression": true,
        "value": "$required_field != null && $required_field != \"\" ? \"VALID\" : \"MISSING_DATA\""
    },
    "targetPath": {
        "value": "data_quality_flag"
    }
}
```

## 🚀 Performance Optimization

### Efficient Null Checking
```json
// ✅ Efficient
"value": "$field?.trim() || \"default\""

// ❌ Less efficient  
"value": "$field != null ? ($field.trim() != \"\" ? $field.trim() : \"default\") : \"default\""
```

### Minimal Processing
```json
// Only process if needed
"value": "$needs_processing == true ? $field.toUpperCase().trim() : $field"
```

## 📋 Best Practices Checklist

### Before Creating Transformations
- [ ] **Understand Source Data** - Know field types and possible values
- [ ] **Define Business Rules** - Document transformation logic clearly
- [ ] **Plan Error Handling** - Handle null, empty, and invalid data
- [ ] **Consider Performance** - Optimize for expected data volumes

### During Implementation
- [ ] **Quote String Literals** - All string constants in double quotes
- [ ] **Use Null-Safe Access** - Always enable nullSafeAccess setting
- [ ] **Test Edge Cases** - Verify with null, empty, and boundary values
- [ ] **Add Descriptive Names** - Clear target field names

### After Implementation
- [ ] **Validate Expressions** - Check syntax with validation tools
- [ ] **Test with Sample Data** - Verify transformations work correctly
- [ ] **Document Logic** - Add notes explaining complex business rules
- [ ] **Review Performance** - Ensure acceptable execution time

---

**Remember**: Good transformations are predictable, testable, and handle edge cases gracefully. When in doubt, make the logic explicit rather than clever.