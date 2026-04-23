```markdown
# RasMol Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches you the core development patterns and conventions used in the RasMol TypeScript codebase. You'll learn about file naming, import/export styles, commit message habits, and how to write and run tests. While no specific frameworks or automated workflows are detected, this guide provides best practices for contributing to and maintaining the RasMol project.

## Coding Conventions

### File Naming
- Use **camelCase** for file names.
  - Example: `moleculeParser.ts`, `renderEngine.ts`

### Import Style
- Use **relative imports** for referencing modules within the codebase.
  - Example:
    ```typescript
    import { parseAtoms } from './atomParser';
    ```

### Export Style
- Use **named exports** for all modules.
  - Example:
    ```typescript
    export function renderMolecule() { ... }
    export const DEFAULT_COLOR = '#FFFFFF';
    ```

### Commit Messages
- Freeform commit messages, no strict prefixing.
- Average commit message length: ~43 characters.
  - Example: `Fix atom color rendering for hydrogens`

## Workflows

### Adding a New Feature
**Trigger:** When implementing a new functionality  
**Command:** `/add-feature`

1. Create a new TypeScript file using camelCase naming.
2. Write your feature using named exports.
3. Use relative imports to include dependencies.
4. Add or update corresponding test files (`*.test.ts`).
5. Commit your changes with a clear, concise message.
6. Open a pull request for review.

### Fixing a Bug
**Trigger:** When resolving a reported issue  
**Command:** `/fix-bug`

1. Locate the relevant module using camelCase file names.
2. Apply your fix, maintaining the import/export conventions.
3. Update or add tests to cover the bug fix.
4. Commit with a descriptive message about the fix.
5. Submit your changes for review.

### Writing Tests
**Trigger:** When adding or updating code  
**Command:** `/write-test`

1. Create or update a test file matching the pattern `*.test.ts`.
2. Write tests for all new or changed functionality.
3. Use the project's preferred (unknown) testing framework.
4. Run tests to ensure correctness before committing.

## Testing Patterns

- Test files are named with the pattern `*.test.ts`.
  - Example: `moleculeParser.test.ts`
- The specific testing framework is not detected; follow existing test patterns in the repository.
- Place tests alongside or near the files they cover.

## Commands
| Command      | Purpose                                 |
|--------------|-----------------------------------------|
| /add-feature | Steps to add a new feature              |
| /fix-bug     | Steps to fix a bug                      |
| /write-test  | Steps to write or update tests          |
```
