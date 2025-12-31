# Contributing to BerkAI

Thank you for your interest in contributing to BerkAI! This document provides guidelines and instructions for contributing to the project.

## 🌟 How to Get Started

### Prerequisites for Contributors

Before you start contributing, make sure you have:

1. **Completed the setup** described in [README.md](./README.md)
2. **Verified your environment** by successfully running both backend and frontend
3. **Familiarized yourself** with the project structure and codebase

### First-Time Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/BerkAI.git
   cd BerkAI
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/bberkaysari/BerkAI.git
   ```

4. **Set up the development environment** following the README

5. **Create a branch** for your work:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

## 🔄 Development Workflow

### 1. Keep Your Fork Updated

Before starting new work, sync with upstream:

```bash
git checkout main
git fetch upstream
git merge upstream/main
git push origin main
```

### 2. Create a Feature Branch

```bash
git checkout -b feature/descriptive-name
# or for bug fixes
git checkout -b fix/descriptive-name
```

### 3. Make Your Changes

- Write clean, readable code
- Follow the coding standards (see below)
- Add comments where necessary
- Update documentation if needed

### 4. Test Your Changes

#### Backend Testing
```bash
cd backend
dotnet test
dotnet build
```

#### Frontend Testing
```bash
cd frontend
npm run lint
npm run build
npm test  # if tests are available
```

### 5. Commit Your Changes

Write clear, descriptive commit messages:

```bash
git add .
git commit -m "feat: add user profile page"
# or
git commit -m "fix: resolve cart total calculation error"
```

**Commit Message Format**:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, missing semicolons, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

### 6. Push and Create Pull Request

```bash
git push origin your-branch-name
```

Then create a Pull Request on GitHub:
1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill in the PR template (see below)
5. Submit the PR

## 📝 Pull Request Guidelines

### PR Title Format

Use the same format as commit messages:
- `feat: add payment integration`
- `fix: resolve authentication bug`
- `docs: update setup instructions`

### PR Description Template

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update

## Changes Made
- List key changes
- Include any architectural decisions
- Note any breaking changes

## Testing Done
- [ ] Backend builds successfully
- [ ] Frontend builds successfully
- [ ] Existing tests pass
- [ ] New tests added (if applicable)
- [ ] Manually tested the changes

## Screenshots (if applicable)
Add screenshots for UI changes

## Related Issues
Closes #issue_number
```

### PR Review Process

1. At least one maintainer must review and approve
2. All CI checks must pass
3. No merge conflicts
4. Follow-up on review comments promptly
5. Squash commits if requested

## 💻 Coding Standards

### Backend (.NET/C#)

1. **Naming Conventions**:
   - PascalCase for classes, methods, properties: `UserService`, `GetUserById`
   - camelCase for local variables and parameters: `userId`, `userName`
   - Private fields with underscore prefix: `_dbContext`, `_logger`

2. **Code Organization**:
   - Follow Clean Architecture principles
   - Keep controllers thin, business logic in services
   - Use dependency injection
   - Separate concerns (Domain, Application, Infrastructure)

3. **Documentation**:
   ```csharp
   /// <summary>
   /// Gets a user by their unique identifier
   /// </summary>
   /// <param name="userId">The unique user identifier</param>
   /// <returns>The user if found, null otherwise</returns>
   public async Task<User?> GetUserByIdAsync(Guid userId)
   ```

4. **Error Handling**:
   - Use try-catch for expected errors
   - Return appropriate HTTP status codes
   - Log errors appropriately
   - Use custom exceptions when needed

5. **Async/Await**:
   - Use async/await for I/O operations
   - Suffix async methods with "Async": `GetUserAsync()`
   - Don't block on async code

### Frontend (Next.js/TypeScript)

1. **Naming Conventions**:
   - PascalCase for components: `UserProfile.tsx`, `ProductCard.tsx`
   - camelCase for functions, variables: `getUserData`, `isAuthenticated`
   - UPPER_CASE for constants: `API_BASE_URL`, `MAX_ITEMS`

2. **Component Structure**:
   ```typescript
   // Imports
   import React from 'react';
   
   // Types/Interfaces
   interface ProductCardProps {
     product: Product;
     onAddToCart: (id: string) => void;
   }
   
   // Component
   export function ProductCard({ product, onAddToCart }: ProductCardProps) {
     // Component logic
     return (
       // JSX
     );
   }
   ```

3. **File Organization**:
   - One component per file
   - Co-locate related files (component + styles + tests)
   - Use barrel exports (index.ts) for cleaner imports

4. **State Management**:
   - Use Zustand for global state
   - Use React Query for server state
   - Local state with useState for component-specific state
   - Minimize prop drilling

5. **TypeScript**:
   - Always type your props and state
   - Avoid `any` type - use `unknown` if necessary
   - Use interfaces for object shapes
   - Use type aliases for unions/intersections

6. **Styling**:
   - Use Tailwind CSS utility classes
   - Keep styles maintainable and consistent
   - Use the `clsx` utility for conditional classes
   - Follow mobile-first approach

### General Best Practices

1. **DRY (Don't Repeat Yourself)**:
   - Extract reusable logic into functions/components
   - Create utilities for common operations

2. **KISS (Keep It Simple, Stupid)**:
   - Write simple, readable code
   - Avoid over-engineering
   - Clear is better than clever

3. **YAGNI (You Aren't Gonna Need It)**:
   - Don't add functionality until needed
   - Focus on current requirements

4. **Comments**:
   - Write self-documenting code
   - Add comments for complex logic
   - Explain "why", not "what"

5. **Testing**:
   - Write tests for critical business logic
   - Test edge cases
   - Keep tests maintainable

## 🐛 Reporting Bugs

### Before Reporting

1. Check existing issues to avoid duplicates
2. Verify the bug in the latest version
3. Test in a clean environment if possible

### Bug Report Template

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. See error

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: [e.g., Windows 11, macOS 14]
- Browser: [e.g., Chrome 120, Firefox 121]
- Backend Version: [e.g., .NET 9.0]
- Frontend Version: [e.g., Next.js 16.0]

## Screenshots
If applicable

## Additional Context
Any other relevant information
```

## 💡 Feature Requests

We welcome feature suggestions! Please:

1. **Check existing issues** to avoid duplicates
2. **Clearly describe** the feature and its benefits
3. **Explain use cases** - how would it be used?
4. **Consider alternatives** - are there other ways to achieve this?

### Feature Request Template

```markdown
## Feature Description
Clear description of the proposed feature

## Problem It Solves
What problem does this feature address?

## Proposed Solution
How should this feature work?

## Alternatives Considered
Other approaches you've thought about

## Additional Context
Mockups, examples, or any other context
```

## 🔍 Code Review Guidelines

### For Authors

- Respond to reviews promptly
- Be open to feedback
- Ask questions if unclear
- Make requested changes or explain why not

### For Reviewers

- Be respectful and constructive
- Focus on the code, not the person
- Explain your suggestions
- Approve when satisfied

### Review Checklist

- [ ] Code follows project standards
- [ ] No obvious bugs or security issues
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] Performance considerations addressed
- [ ] Backward compatibility maintained (or noted)

## 🏗️ Project Structure Guidelines

### Backend Structure

```
backend/src/
├── FashionEcommerce.Domain/
│   ├── Entities/          # Domain models
│   ├── Interfaces/        # Repository interfaces
│   └── ValueObjects/      # Value objects
├── FashionEcommerce.Application/
│   ├── DTOs/              # Data transfer objects
│   ├── Services/          # Business logic
│   └── Interfaces/        # Service interfaces
├── FashionEcommerce.Infrastructure/
│   ├── Data/              # DbContext, migrations
│   ├── Repositories/      # Repository implementations
│   └── Services/          # External service implementations
└── FashionEcommerce.WebAPI/
    ├── Controllers/       # API endpoints
    ├── Middleware/        # Custom middleware
    └── Program.cs         # Application entry point
```

### Frontend Structure

```
frontend/
├── app/                   # Next.js App Router
│   ├── (auth)/           # Auth-related pages (grouped route)
│   ├── (shop)/           # Shop pages (grouped route)
│   ├── admin/            # Admin pages
│   └── layout.tsx        # Root layout
├── components/
│   ├── ui/               # Reusable UI components
│   ├── layout/           # Layout components
│   └── [feature]/        # Feature-specific components
├── lib/
│   ├── api/              # API client functions
│   ├── stores/           # Zustand stores
│   └── utils/            # Utility functions
└── types/                # TypeScript type definitions
```

## 🤝 Getting Help

If you need help:

1. **Check the documentation** - README, this guide, code comments
2. **Search existing issues** - your question might be answered
3. **Ask in discussions** - use GitHub Discussions for questions
4. **Create an issue** - for bugs or feature requests
5. **Contact maintainers** - as a last resort for urgent matters

## 📧 Communication

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and general discussion
- **Pull Requests**: Code contributions
- **Email**: [Add contact email if applicable]

## 🎓 Learning Resources

### Backend (.NET)
- [.NET Documentation](https://learn.microsoft.com/en-us/dotnet/)
- [Entity Framework Core](https://learn.microsoft.com/en-us/ef/core/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Frontend (Next.js)
- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev/)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [Tailwind CSS](https://tailwindcss.com/docs)

### AI/ML
- [HR-VITON Paper](https://arxiv.org/abs/2206.14180)
- [PyTorch Documentation](https://pytorch.org/docs/)

## 📜 Code of Conduct

### Our Standards

- **Be respectful**: Treat everyone with respect and kindness
- **Be collaborative**: Work together towards common goals
- **Be patient**: Help others learn and grow
- **Be inclusive**: Welcome people from all backgrounds
- **Be constructive**: Provide helpful feedback

### Unacceptable Behavior

- Harassment, discrimination, or hate speech
- Trolling or insulting comments
- Public or private harassment
- Publishing others' private information
- Other conduct inappropriate in a professional setting

### Enforcement

Violations may result in:
1. Warning
2. Temporary ban
3. Permanent ban

Report violations to [maintainer email/contact].

## 🙏 Thank You!

Your contributions make this project better for everyone. We appreciate your time and effort!

---

**Questions?** Feel free to ask in GitHub Discussions or create an issue.
