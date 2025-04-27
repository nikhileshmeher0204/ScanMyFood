# Contributing to FoodScanAI

Thank you for your interest in contributing to FoodScanAI! We aim to make food scanning and analysis more accessible through artificial intelligence. This document provides guidelines for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please read it before contributing. We expect all contributors to:
- Be respectful and inclusive
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list to avoid duplicates. When creating a bug report, include as many details as possible:

- A clear and descriptive title
- Exact steps to reproduce the issue
- Expected behavior vs actual behavior
- Screenshots if applicable
- Your environment details (OS, Python version, dependencies)
- Any relevant logs or error messages

### Suggesting Enhancements

Enhancement suggestions are welcome! When proposing an enhancement:

- Use a clear and descriptive title
- Provide a detailed description of the proposed functionality
- Explain why this enhancement would be useful
- Include code examples if possible
- Consider both the impact and implementation complexity

### Pull Requests

1. Fork the repository and create your branch from `main`
2. If you've added code that should be tested, add tests
3. Ensure all tests pass
4. Update the documentation accordingly
5. Follow the coding style and conventions
6. Issue the pull request!

## Development Setup

1. Clone the repository:
```bash
git clone https://github.com/nikhileshmeher0204/FoodScanAI.git
cd FoodScanAI
```

2. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Coding Guidelines

### Python Style Guide

- Follow PEP 8 guidelines
- Use meaningful variable and function names
- Add docstrings to all functions and classes
- Keep functions focused and single-purpose
- Comment complex logic
- Use type hints where appropriate

### Commit Messages

- Use clear and meaningful commit messages
- Start with a verb in imperative mood
- Keep the first line under 50 characters
- Add detailed description if needed

Example:
```
Add image preprocessing pipeline

- Implement resize functionality
- Add color normalization
- Include basic filtering options
```

### Testing

- Write unit tests for new functionality
- Ensure existing tests pass
- Test edge cases
- Include integration tests where necessary
- Aim for good test coverage

## Documentation

- Update README.md if you change functionality
- Document new features
- Update API documentation
- Include docstrings for new functions/classes
- Add comments for complex logic
- Update requirements.txt if adding dependencies

## Review Process

1. A maintainer will review your PR
2. Changes may be requested
3. Once approved, your PR will be merged
4. Your contribution will be acknowledged

## Questions?

Feel free to open an issue for any questions not covered here. We're happy to help!

## License

By contributing to FoodScanAI, you agree that your contributions will be licensed under the same license as the project.
