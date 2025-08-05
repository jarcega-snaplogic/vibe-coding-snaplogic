/**
 * Intelligent caching module for SnapLogic snap schemas
 * Optimizes memory usage and API calls with multi-index caching
 */

export class SchemaCache {
  constructor() {
    // Compact catalog storage - only essential fields
    this.catalog = new Map(); // class_id → {name, category, description, version}
    
    // Fast lookup indexes
    this.byCategory = new Map(); // category → Set of class_ids
    this.searchIndex = new Map(); // token → Set of class_ids
    
    // Full schemas loaded on-demand with LRU eviction
    this.fullSchemas = new Map(); // class_id → {schema, lastAccess}
    this.schemaAccessOrder = []; // Track access order for LRU
    
    // Cache metadata
    this.catalogLastFetch = null;
    this.catalogTTL = 24 * 60 * 60 * 1000; // 24 hours
    this.maxFullSchemas = 50; // Limit memory usage
    this.isLoading = false;
  }

  /**
   * Check if catalog needs refresh
   */
  needsCatalogRefresh() {
    if (!this.catalogLastFetch) return true;
    const age = Date.now() - this.catalogLastFetch;
    return age > this.catalogTTL;
  }

  /**
   * Process and index the catalog response
   * Extracts only essential fields to minimize memory usage
   */
  processCatalog(apiResponse) {
    this.catalog.clear();
    this.byCategory.clear();
    this.searchIndex.clear();
    
    // Handle the actual API response structure
    const snapData = apiResponse.response_map || apiResponse;
    
    // Process each snap directly from response_map
    for (const [classId, snapSchema] of Object.entries(snapData)) {
      // Skip if this doesn't look like a snap schema
      if (!snapSchema || typeof snapSchema !== 'object' || !snapSchema.class_map) {
        continue;
      }
      
      // Extract snap name from class_map info
      let snapName = classId;
      let description = snapSchema.description || '';
      
      if (snapSchema.class_map && snapSchema.class_map.info) {
        snapName = snapSchema.class_map.info.label?.value || snapName;
        description = snapSchema.class_map.info.notes?.value || description;
      }
      
      // Determine category from class_id
      const categoryMatch = classId.match(/com-snaplogic-snaps-([^-]+)/);
      const category = categoryMatch ? categoryMatch[1] : 'unknown';
      
      if (!this.byCategory.has(category)) {
        this.byCategory.set(category, new Set());
      }
      
      // Extract essential fields only
      const compactSnap = {
        name: snapName,
        category: category,
        description: description,
        version: snapSchema.class_version || 1
      };
      
      // Store in catalog
      this.catalog.set(classId, compactSnap);
      
      // Add to category index
      this.byCategory.get(category).add(classId);
      
      // Build search index
      this.indexSnapForSearch(classId, compactSnap);
    }
    
    this.catalogLastFetch = Date.now();
  }

  /**
   * Build search index for a snap
   */
  indexSnapForSearch(classId, snap) {
    const text = `${snap.name} ${snap.description}`.toLowerCase();
    const tokens = this.tokenize(text);
    
    for (const token of tokens) {
      if (!this.searchIndex.has(token)) {
        this.searchIndex.set(token, new Set());
      }
      this.searchIndex.get(token).add(classId);
    }
  }

  /**
   * Simple tokenization for search
   */
  tokenize(text) {
    return text
      .split(/[\s\-_\.]+/)
      .filter(token => token.length > 2)
      .map(token => token.toLowerCase());
  }

  /**
   * Search snaps by query
   */
  searchSnaps(query, category = null) {
    const queryTokens = this.tokenize(query.toLowerCase());
    const matches = new Map(); // class_id → score
    
    // Score based on token matches
    for (const token of queryTokens) {
      if (this.searchIndex.has(token)) {
        for (const classId of this.searchIndex.get(token)) {
          const score = matches.get(classId) || 0;
          matches.set(classId, score + 1);
        }
      }
    }
    
    // Filter by category if specified
    let results = Array.from(matches.entries());
    if (category) {
      const categorySnaps = this.byCategory.get(category.toLowerCase());
      if (categorySnaps) {
        results = results.filter(([classId]) => categorySnaps.has(classId));
      }
    }
    
    // Sort by score and return snap info
    return results
      .sort((a, b) => b[1] - a[1])
      .map(([classId]) => ({
        class_id: classId,
        ...this.catalog.get(classId)
      }));
  }

  /**
   * Get or fetch full schema with LRU cache management
   */
  getFullSchema(classId) {
    if (this.fullSchemas.has(classId)) {
      // Update access time
      const schema = this.fullSchemas.get(classId);
      schema.lastAccess = Date.now();
      
      // Move to end of access order
      const index = this.schemaAccessOrder.indexOf(classId);
      if (index > -1) {
        this.schemaAccessOrder.splice(index, 1);
      }
      this.schemaAccessOrder.push(classId);
      
      return schema.data;
    }
    
    return null; // Caller should fetch from API
  }

  /**
   * Store full schema with LRU eviction
   */
  storeFullSchema(classId, schemaData) {
    // Evict oldest if at capacity
    if (this.fullSchemas.size >= this.maxFullSchemas) {
      const oldest = this.schemaAccessOrder.shift();
      this.fullSchemas.delete(oldest);
    }
    
    // Store new schema
    this.fullSchemas.set(classId, {
      data: schemaData,
      lastAccess: Date.now()
    });
    this.schemaAccessOrder.push(classId);
  }

  /**
   * Get all categories with counts
   */
  getCategories() {
    const categories = [];
    for (const [category, snaps] of this.byCategory) {
      categories.push({
        name: category,
        count: snaps.size
      });
    }
    return categories.sort((a, b) => a.name.localeCompare(b.name));
  }

  /**
   * Get basic info for a snap
   */
  getSnapInfo(classId) {
    return this.catalog.get(classId) || null;
  }

  /**
   * Clear all caches
   */
  clear() {
    this.catalog.clear();
    this.byCategory.clear();
    this.searchIndex.clear();
    this.fullSchemas.clear();
    this.schemaAccessOrder = [];
    this.catalogLastFetch = null;
  }
}