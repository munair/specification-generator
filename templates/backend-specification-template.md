# Backend Feature Specification: [Lambda Function/API Name]

---
**Domain**: Backend (Lambda/API)
**Guideline**: `backend-feature-specification-guidelines.md`
**Testing Approach**: Node.js native modules only (`assert`, `fs`, `path`)
**Service Type**: [Lambda Function | REST API | Data Processor]
---

## Overview
[One paragraph describing what this service does and why it's needed. Focus on the business problem being solved.]

## Goals
- [Primary objective - what key capability will this provide?]
- [Performance goal - response time, throughput, etc.]
- [Integration goal - what systems will this connect?]

## Functional Requirements

### Core Functionality
FR1: The service must [primary behavior]
FR2: The API must [endpoint behavior]
FR3: Data validation must [validation requirement]
FR4: The service must NOT [prohibited behavior]
FR5: Authorization must [security requirement]

### Error Handling
FR6: When [error condition], return [HTTP status] with [error structure]
FR7: If [timeout occurs], the service must [fallback behavior]

## Non-Goals (Explicit Boundaries)
- This service does NOT [common misconception]
- We will NOT support [out of scope feature]
- No [premature optimization]
- Not responsible for [external system behavior]
- Does NOT include [future enhancement]

## Technical Considerations

### Architecture
- **Runtime**: Node.js 20.x
- **Handler**: `index.handler` (CommonJS)
- **Timeout**: [seconds]
- **Memory**: [MB]
- **Concurrency**: [reserved/provisioned if needed]

### Dependencies
- Node.js native modules only (no external packages for core logic)
- AWS SDK v3 for service integrations
- DynamoDB for [data storage needs]

### Data Storage
- **DynamoDB Table**: [table name and structure]
- **S3 Bucket**: [if needed for file storage]
- **Caching**: [ElastiCache/CloudFront if applicable]

## Testing Considerations

### Unit Tests
- Location: `tests/utilities/`, `tests/services/`
- Approach: Node.js `assert` module only
- Mocking: Via `require.cache` manipulation

### Integration Tests
- Location: `tests/integration/`
- Approach: Test handler with mocked AWS services
- Coverage: All API endpoints and error paths

### Test Scenarios
- Valid input processing
- Invalid input rejection with proper errors
- Timeout handling
- DynamoDB failures
- Authorization failures

## API Specification

### Endpoint: [POST /resource]
**Request**:
```json
{
  "field1": "string",
  "field2": number
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {}
}
```

**Error Response (4xx/5xx)**:
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

## Success Metrics
- [Response time]: < [X]ms for 95th percentile
- [Error rate]: < [X]% excluding client errors
- [Availability]: [99.9]% uptime

## Authorization & Security
- API Key validation via DynamoDB `allowedScopes` table
- Request origin validation
- Rate limiting: [X requests/minute]
- Input sanitization for all parameters

## Archival Cross-Reference

**IMPORTANT**: After implementation, follow the **ARCHIVAL PROTOCOL** in `implementation-tasks-creation-guidelines.md`:

1. Mark ALL tasks complete (`- [ ]` → `- [x]`)
2. Rename from `implementing-` to `implementation-log-`
3. Move to `/documentation/tasks/completed/`
4. Tag as `[service-name]-[architecture-pattern]`

---

## Quick Checklist
☐ Business problem clearly defined
☐ API contract specified
☐ Error handling comprehensive
☐ DynamoDB schema defined
☐ Test strategy uses Node.js native only
☐ Authorization approach specified
☐ Performance targets measurable
☐ Archival workflow understood