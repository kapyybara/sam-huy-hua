# BaseType Reference — Tham Khảo Kiểu Dữ Liệu

Tài liệu này liệt kê tất cả các `BaseType` được Saul server hỗ trợ, kèm JSON format.

## Primitive Types

### string
```json
{ "type": "string" }
```

### string với enum
```json
{ "type": "string", "enum": ["DRAFT", "PENDING", "ACTIVE", "EXPIRED"] }
```

### number
```json
{ "type": "number" }
```

### number với enum
```json
{ "type": "number", "enum": [1, 2, 3] }
```

### boolean
```json
{ "type": "boolean" }
```

### Date
```json
{ "type": "Date" }
```

### null (dùng cho void return type)
```json
{ "type": "null" }
```

### any
```json
{ "type": "any" }
```

## Complex Types

### Array
```json
{
  "type": "Array",
  "itemType": { "type": "string" }
}
```

Array of Models:
```json
{
  "type": "Array",
  "itemType": {
    "type": "Model",
    "ref": { "name": "User", "module": "user" }
  }
}
```

### Record (Map)
```json
{
  "type": "Record",
  "keyType": { "type": "string" },
  "valueType": { "type": "number" }
}
```

### Union
```json
{
  "type": "Union",
  "types": [
    { "type": "string" },
    { "type": "null" }
  ]
}
```

### Model (tham chiếu đến ModelDefinition)
```json
{
  "type": "Model",
  "ref": {
    "name": "User",
    "module": "user"
  }
}
```

> `ref.name` = tên của ModelDefinition  
> `ref.module` = tên module chứa model đó

### File
```json
{ "type": "File" }
```

## Sử dụng trong FieldDefinition

```json
{
  "name": "fieldName",
  "type": { "type": "string" },
  "description": "Mô tả field (optional)"
}
```

## Sử dụng làm returnType trong ServiceFunction

Dùng `{ "type": "null" }` cho function không trả về gì (void):
```json
{
  "name": "deleteUser",
  "returnType": { "type": "null" },
  ...
}
```

Dùng Model ref cho function trả về 1 object:
```json
{
  "name": "getUser",
  "returnType": {
    "type": "Model",
    "ref": { "name": "User", "module": "user" }
  },
  ...
}
```
