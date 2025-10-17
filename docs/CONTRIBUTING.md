# Contributing to AndroidXiboClientEink

Thank you for considering contributing! This document outlines the guidelines for contributing to this project.

## How to Contribute

### Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Use the bug report template** when creating a new issue
3. **Include**:
   - Device model and Android version
   - Steps to reproduce
   - Expected vs actual behavior
   - Logs if available

### Suggesting Features

1. **Check existing feature requests** first
2. **Open a discussion** to gauge interest
3. **Describe**:
   - Use case and motivation
   - Proposed solution
   - Alternative approaches considered

### Code Contributions

#### Setup Development Environment

```bash
# Clone repository
git clone https://github.com/NUbem000/AndroidXiboclienteink.git
cd AndroidXiboclienteink

# Open in Android Studio
# File > Open > Select AndroidXiboclienteink

# Build project
./gradlew build

# Run tests
./gradlew test
```

#### Before Submitting

1. **Follow Kotlin style guide**
2. **Write tests** for new functionality
3. **Update documentation** if needed
4. **Run code analysis**:
   ```bash
   ./gradlew lint
   ./gradlew detekt
   ```

#### Pull Request Process

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make changes** with clear, atomic commits
4. **Push** to your fork
5. **Open a Pull Request** with:
   - Clear description of changes
   - Reference to related issues
   - Screenshots/videos for UI changes
   - Test results

### Code Style

- Use **Kotlin** for app code
- Use **C++17** for native code
- Follow **Android conventions**
- Maximum line length: **120 characters**
- Use **meaningful variable names**

Example:
```kotlin
// GOOD
fun optimizeBitmapForEink(source: Bitmap): Bitmap {
    // Clear implementation
}

// BAD
fun opt(b: Bitmap): Bitmap {
    // Unclear purpose
}
```

### Commit Messages

Format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Build/tooling changes

Example:
```
feat(eink): Add A2 refresh mode support

Implement A2 (Animation) refresh mode for faster updates
during scrolling operations. This improves perceived
performance on e-ink displays.

Closes #42
```

### Testing

- **Unit tests** for all business logic
- **Integration tests** for API/database
- **UI tests** for critical flows
- **Native tests** for C++ code

```bash
# Run all tests
./gradlew test connectedAndroidTest

# Run specific test
./gradlew test --tests EinkDisplayManagerTest
```

### Documentation

- Update **README.md** for user-facing changes
- Update **ARCHITECTURE.md** for structural changes
- Add **inline comments** for complex logic
- Update **CHANGELOG.md**

## Areas Needing Help

Priority areas:
1. 🧪 **Testing** on different e-ink devices
2. 🎨 **Widget implementations** (RSS, Weather, etc.)
3. 🚀 **Performance optimizations**
4. 📚 **Documentation improvements**
5. 🌍 **Translations**

## Community

- **GitHub Discussions**: Questions and ideas
- **Issues**: Bug reports and feature requests
- **Pull Requests**: Code contributions

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help create a welcoming environment

## License

By contributing, you agree that your contributions will be licensed under the **GNU Affero General Public License v3.0**.

---

**Questions?** Open a discussion or contact the maintainers.

Thank you for contributing! 🎉
